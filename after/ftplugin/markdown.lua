-- Buffer-local todo state keymaps for the files checkmate manages (TODO.md, etc.).
--
-- These live here, under after/ (sourced last in the runtimepath), for two reasons:
--   * <CR> must beat follow-md-links.nvim, whose markdown ftplugin claims <CR> for
--     link-following in every markdown buffer.
--   * <CR> and [ / ] share the same get-state/set-state logic, kept together.
--
-- Guarded to checkmate's default `files` patterns so plain markdown is untouched
-- (it keeps Enter-follows-link and the default [ / ] bracket motions).

local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t'):lower()
local is_todo = name == 'todo' or name == 'todo.md' or name:match '%.todo$' or name:match '%.todo%.md$'

if not is_todo then
  return
end

-- <CR>: smart advance.
--   cancelled -> open, open -> done, in progress -> done, done -> open.
local CR_NEXT = {
  cancelled = 'unchecked',
  unchecked = 'checked',
  in_progress = 'checked',
  checked = 'unchecked',
}

-- [ / ]: step through the full sequence. No wrapping -- the ends are no-ops.
local CYCLE = { 'cancelled', 'unchecked', 'in_progress', 'checked' }

-- Resolve the todo under the cursor, ask `pick` for the target state given the
-- current one, and apply it. `pick` returning nil/false means "do nothing".
local function transition(pick)
  local checkmate = require 'checkmate'
  local todo = checkmate.get_todo()
  if not todo then
    return
  end
  local target = pick(todo.state)
  if target then
    checkmate.set_todo_state(todo, target)
  end
end

local function index_of(state)
  for i, s in ipairs(CYCLE) do
    if s == state then
      return i
    end
  end
end

vim.keymap.set('n', '<CR>', function()
  transition(function(state)
    return CR_NEXT[state]
  end)
end, { buffer = true, desc = 'Todo: advance state' })

vim.keymap.set('n', ']', function()
  transition(function(state)
    local i = index_of(state)
    return i and CYCLE[i + 1] -- nil past the end => no wrap
  end)
end, { buffer = true, desc = 'Todo: next state' })

vim.keymap.set('n', '[', function()
  transition(function(state)
    local i = index_of(state)
    return i and i > 1 and CYCLE[i - 1] -- false at the start => no wrap
  end)
end, { buffer = true, desc = 'Todo: previous state' })
