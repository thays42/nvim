-- Telescope extension for searching R documentation
-- Builds a cached index of all help topics via Rscript (no running R session needed)

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local previewers = require('telescope.previewers')

local M = {}

-- Cache directory in nvim state folder
local cache_dir = vim.fn.stdpath('state') .. '/r_help'
local index_cache_file = cache_dir .. '/index.json'
local pages_cache_dir = cache_dir .. '/pages'

-- In-memory caches
local help_index = nil
local index_loading = false
local help_pages_cache = {} -- In-memory cache for help pages

-- Preview debouncing
local preview_timer = nil
local preview_debounce_ms = 150

-- Check if R is running via R.nvim
local function is_r_running()
  return vim.g.R_Nvim_status and vim.g.R_Nvim_status >= 7
end

-- Ensure cache directories exist
local function ensure_cache_dirs()
  vim.fn.mkdir(cache_dir, 'p')
  vim.fn.mkdir(pages_cache_dir, 'p')
end

-- Get cache file path for a help page
local function get_page_cache_path(package, topic)
  -- Sanitize for filesystem (replace non-alphanumeric with _)
  local safe_name = (package .. '_' .. topic):gsub('[^%w%-_]', '_')
  return pages_cache_dir .. '/' .. safe_name .. '.txt'
end

-- Load help page from disk cache
local function load_cached_page(package, topic)
  local path = get_page_cache_path(package, topic)
  if vim.fn.filereadable(path) == 1 then
    local content = table.concat(vim.fn.readfile(path), '\n')
    return content
  end
  return nil
end

-- Save help page to disk cache
local function save_page_cache(package, topic, content)
  ensure_cache_dirs()
  local path = get_page_cache_path(package, topic)
  vim.fn.writefile(vim.split(content, '\n'), path)
end

-- Get current .libPaths() with their mtimes (for cache validation)
local function get_libpaths_with_mtimes()
  local result = vim.system(
    { 'Rscript', '-e', 'cat(.libPaths(), sep = "\\n")' },
    { text = true, env = rscript_env }
  ):wait()
  if result.code == 0 and result.stdout then
    local entries = {}
    for line in result.stdout:gmatch('[^\n]+') do
      local stat = vim.loop.fs_stat(line)
      local mtime = stat and stat.mtime.sec or 0
      table.insert(entries, { path = line, mtime = mtime })
    end
    return entries
  end
  return nil
end

-- Load index from disk cache (validates libpaths and mtimes)
local function load_cached_index()
  if vim.fn.filereadable(index_cache_file) == 1 then
    local content = table.concat(vim.fn.readfile(index_cache_file), '\n')
    local ok, data = pcall(vim.json.decode, content)
    if ok and data and data.libpaths and data.index then
      -- Validate libpaths and mtimes match current environment
      local current = get_libpaths_with_mtimes()
      if current then
        -- Quick check: same number of paths?
        if #current ~= #data.libpaths then
          return nil
        end
        -- Compare each path and mtime
        for i, entry in ipairs(current) do
          local cached = data.libpaths[i]
          if not cached or cached.path ~= entry.path or cached.mtime ~= entry.mtime then
            return nil
          end
        end
        return data.index
      end
      -- Couldn't get current libpaths, use cache anyway
      return data.index
    end
  end
  return nil
end

-- Save index to disk cache (includes libpaths with mtimes for validation)
local function save_index_cache(index, libpaths_with_mtimes)
  ensure_cache_dirs()
  local cache_data = {
    libpaths = libpaths_with_mtimes,
    index = index,
  }
  local ok, json = pcall(vim.json.encode, cache_data)
  if ok then
    vim.fn.writefile({ json }, index_cache_file)
  end
end

-- Clean up backspace-based formatting from Rd2txt output
-- Rd2txt uses _\bX for underline and X\bX for bold (terminal escape sequences)
local function clean_rd_output(text)
  -- Remove underline formatting: _\bX -> X
  text = text:gsub('_\b(.)', '%1')
  -- Remove bold formatting: X\bX -> X
  text = text:gsub('(.)\b%1', '%1')
  return text
end

-- Environment variables for Rscript calls
local rscript_env = {
  RENV_CONFIG_SYNCHRONIZED_CHECK = 'FALSE', -- Suppress renv sync warnings
}

-- Build the help index using Rscript (background process)
local function build_index(callback)
  if index_loading then return end
  index_loading = true

  vim.notify('Building R help index...', vim.log.levels.INFO)

  -- R script to build the index
  local r_code = [[
db <- hsearch_db()
if (!is.null(db) && !is.null(db$Base)) {
  base <- db$Base
  out <- paste(base$Package, base$Name, base$Title, base$LibPath, sep = "\t")
  cat(out, sep = "\n")
}
]]

  -- Run Rscript asynchronously
  vim.system(
    { 'Rscript', '-e', r_code },
    { text = true, env = rscript_env },
    vim.schedule_wrap(function(result)
      index_loading = false

      if result.code ~= 0 then
        vim.notify('Failed to build R help index: ' .. (result.stderr or 'unknown error'), vim.log.levels.ERROR)
        callback(nil)
        return
      end

      local index = {}
      for line in result.stdout:gmatch('[^\n]+') do
        local parts = vim.split(line, '\t', { plain = true })
        if #parts >= 3 then
          table.insert(index, {
            package = parts[1],
            topic = parts[2],
            title = parts[3] or '',
            libpath = parts[4] or '',
          })
        end
      end

      if #index == 0 then
        vim.notify('No R help topics found', vim.log.levels.WARN)
        callback(nil)
        return
      end

      -- Get libpaths with mtimes for cache validation
      local libpaths_with_mtimes = get_libpaths_with_mtimes() or {}

      help_index = index
      save_index_cache(index, libpaths_with_mtimes)
      vim.notify(string.format('R help index built: %d topics', #index), vim.log.levels.INFO)
      callback(index)
    end)
  )
end

-- Fetch help content for a topic
local function fetch_help_content(package, topic, callback)
  -- Check in-memory cache first
  local cache_key = package .. '::' .. topic
  if help_pages_cache[cache_key] then
    callback(help_pages_cache[cache_key])
    return
  end

  -- Check disk cache
  local cached = load_cached_page(package, topic)
  if cached then
    help_pages_cache[cache_key] = cached
    callback(cached)
    return
  end

  -- Fetch from R
  local r_code = string.format(
    [[
tryCatch({
  rd <- utils:::.getHelpFile(help("%s", package = "%s"))
  tools::Rd2txt(rd, package = "%s")
}, error = function(e) {
  cat("Error:", e$message, "\n")
})
]],
    topic,
    package,
    package
  )

  vim.system(
    { 'Rscript', '-e', r_code },
    { text = true, env = rscript_env },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 or not result.stdout or result.stdout == '' then
        callback(nil, result.stderr or 'Unknown error')
        return
      end

      local cleaned = clean_rd_output(result.stdout)
      -- Cache it
      help_pages_cache[cache_key] = cleaned
      save_page_cache(package, topic, cleaned)
      callback(cleaned)
    end)
  )
end

-- Create entry maker for telescope
local function make_entry_maker(opts)
  local displayer = entry_display.create({
    separator = ' ',
    items = {
      { width = 40 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    -- Display as package::topic to match search syntax
    local qualified_name = entry.package .. '::' .. entry.topic
    return displayer({
      { qualified_name, 'TelescopeResultsIdentifier' },
      { entry.title, 'TelescopeResultsComment' },
    })
  end

  return function(item)
    return {
      value = item,
      display = make_display,
      -- Use R's package::function syntax for searching
      -- This lets users type "dplyr::" to see all dplyr functions,
      -- or "dplyr::filter" to narrow down
      ordinal = item.package .. '::' .. item.topic,
      topic = item.topic,
      package = item.package,
      title = item.title,
      libpath = item.libpath,
    }
  end
end

-- Create previewer that shows help content via Rscript
local function make_previewer()
  return previewers.new_buffer_previewer({
    title = 'R Help Preview',
    define_preview = function(self, entry, status)
      -- Show immediate feedback with what we know
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
        entry.package .. '::' .. entry.topic,
        '',
        entry.title,
        '',
        'Loading...',
      })

      -- Cancel any pending preview fetch
      if preview_timer then
        preview_timer:stop()
        preview_timer:close()
        preview_timer = nil
      end

      -- Debounce: wait before fetching
      preview_timer = vim.loop.new_timer()
      preview_timer:start(
        preview_debounce_ms,
        0,
        vim.schedule_wrap(function()
          preview_timer = nil

          -- Check if buffer still valid
          if not vim.api.nvim_buf_is_valid(self.state.bufnr) then return end

          fetch_help_content(entry.package, entry.topic, function(content, err)
            if not vim.api.nvim_buf_is_valid(self.state.bufnr) then return end

            if not content then
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
                'Failed to load help.',
                '',
                err or 'Unknown error',
              })
              return
            end

            local lines = vim.split(content, '\n')
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            vim.api.nvim_set_option_value('filetype', 'rhelp', { buf = self.state.bufnr })
          end)
        end)
      )
    end,
  })
end

-- Open help - prefer R.nvim when available, fall back to buffer display
local function open_help(entry)
  if is_r_running() then
    -- Use R.nvim's integrated help display
    require('r.doc').ask_R_doc(entry.topic, entry.package, false)
  else
    -- Fall back to cached content or fetch
    vim.notify('Fetching help...', vim.log.levels.INFO)

    fetch_help_content(entry.package, entry.topic, function(content, err)
      if not content then
        vim.notify('Failed to load help: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
        return
      end

      -- Create a new buffer for the help
      vim.cmd('split')
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, buf)

      local lines = vim.split(content, '\n')
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Set buffer options
      vim.api.nvim_buf_set_name(buf, entry.topic .. ' {' .. entry.package .. '}')
      vim.api.nvim_set_option_value('filetype', 'rhelp', { buf = buf })
      vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
      vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
      vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

      -- Add q to close
      vim.keymap.set('n', 'q', ':q<CR>', { buffer = buf, silent = true })
    end)
  end
end

-- Check if cache is still valid (compares libpath mtimes)
local function is_cache_valid()
  if vim.fn.filereadable(index_cache_file) == 0 then
    return false
  end
  local content = table.concat(vim.fn.readfile(index_cache_file), '\n')
  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data or not data.libpaths then
    return false
  end
  local current = get_libpaths_with_mtimes()
  if not current or #current ~= #data.libpaths then
    return false
  end
  for i, entry in ipairs(current) do
    local cached = data.libpaths[i]
    if not cached or cached.path ~= entry.path or cached.mtime ~= entry.mtime then
      return false
    end
  end
  return true
end

-- Main picker function
M.r_help = function(opts)
  opts = opts or {}

  local function show_picker(index)
    if not index or #index == 0 then
      vim.notify('No R help topics found', vim.log.levels.WARN)
      return
    end

    pickers
      .new(opts, {
        prompt_title = 'R Documentation',
        finder = finders.new_table({
          results = index,
          entry_maker = make_entry_maker(opts),
        }),
        sorter = conf.generic_sorter(opts),
        previewer = make_previewer(),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              open_help(selection)
            end
          end)

          -- Add mapping to refresh index (rebuilds from R, ignores cache)
          map('i', '<C-r>', function()
            actions.close(prompt_bufnr)
            help_index = nil
            M.r_help(opts)
          end)

          map('n', '<C-r>', function()
            actions.close(prompt_bufnr)
            help_index = nil
            M.r_help(opts)
          end)

          return true
        end,
      })
      :find()
  end

  -- Always validate cache (checks libpath mtimes)
  vim.notify('Checking R help index...', vim.log.levels.INFO)
  if not is_cache_valid() then
    -- Cache invalid - clear in-memory and rebuild
    help_index = nil
    build_index(show_picker)
  elseif help_index then
    -- Cache valid and in-memory - use directly
    show_picker(help_index)
  else
    -- Cache valid but not in memory - load from disk
    local cached = load_cached_index()
    if cached then
      help_index = cached
      show_picker(cached)
    else
      build_index(show_picker)
    end
  end
end

-- Clear all caches (in-memory and disk)
M.clear_cache = function()
  help_index = nil
  help_pages_cache = {}
  -- Remove cache directory
  vim.fn.delete(cache_dir, 'rf')
  vim.notify('R help cache cleared', vim.log.levels.INFO)
end

-- Pre-build index (can be called anytime)
M.prebuild_index = function()
  if help_index then return end
  -- Try disk cache first
  local cached = load_cached_index()
  if cached then
    help_index = cached
    return
  end
  build_index(function(_) end)
end

return require('telescope').register_extension({
  setup = function(ext_config)
    -- Optional: auto-build index on VimEnter
    if ext_config and ext_config.auto_build then
      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          vim.defer_fn(function()
            M.prebuild_index()
          end, 1000)
        end,
      })
    end
  end,
  exports = {
    r_help = M.r_help,
    clear_cache = M.clear_cache,
    prebuild_index = M.prebuild_index,
  },
})
