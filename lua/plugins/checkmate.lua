return {
  -- Interactive markdown todo lists (TODO.md, etc.)
  -- Activates only on TODO-style filenames; coexists with render-markdown.nvim,
  -- which keeps handling all other markdown buffers.
  {
    'bngarren/checkmate.nvim',
    ft = 'markdown',
    opts = {
      files = { 'todo', 'TODO', 'todo.md', 'TODO.md', '*.todo', '*.todo.md' },
      -- Four states, Obsidian-style on-disk markers: open [ ], done [x] (fixed for
      -- the built-ins), in-progress [/], cancelled [-]. The cycling ORDER for the
      -- [ / ] keys is defined explicitly in after/ftplugin/markdown.lua, not by the
      -- `order` field below (which only drives checkmate's own cycle()).
      todo_states = {
        unchecked = { marker = '☐' },
        checked = { marker = '✔' },
        in_progress = { marker = '◐', markdown = '/', type = 'incomplete', order = 3 },
        cancelled = { marker = '✗', markdown = '-', type = 'inactive', order = 1 },
      },
      -- Single-key bindings, all buffer-local (TODO files only). <CR> (advance state)
      -- and [ / ] (cycle states) live in after/ftplugin/markdown.lua: they share the
      -- custom transition logic, and <CR> must load late enough there to beat
      -- follow-md-links.nvim, which claims <CR> in every markdown buffer.
      keys = {
        ['o'] = { rhs = '<cmd>Checkmate create<CR>', desc = 'New todo below', modes = { 'n' } },
        -- "Above" by moving up a line first, then creating below it. On line 1 the
        -- k is a no-op so it falls through to creating below (acceptable edge case).
        ['O'] = { rhs = 'k<cmd>Checkmate create<CR>', desc = 'New todo above', modes = { 'n' } },
        -- Rarer actions keep their <leader>T defaults: <leader>Ta archive, <leader>TF picker.
      },
    },
  },
}
