-- Jobs
function ToggleRTestActiveFile()
  local cmd = "R --quiet --no-save --no-restore -e 'devtools::test_active_file(\"" ..
      vim.fn.expand("%") .. "\", reporter=\"tap\")'"
  ToggleFloatTerm(cmd, nil, false)
end

vim.api.nvim_set_keymap("n", "<leader>;rt", "<cmd>lua ToggleRTestActiveFile()<CR>", { noremap = true, silent = true })

-- Repl
vim.api.nvim_set_keymap("n", "<leader>;rr", "<cmd>:ReplToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rl", "<cmd>:ReplSendArgs devtools::load_all()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>;rd", "<cmd>:ReplSendArgs devtools::document()<CR>",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<enter>", "vas",
  { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<enter>", "<Plug>(ReplSendVisual)",
  { noremap = true, silent = true })

local get_parser_name_and_root = function()
  local lang = vim.bo[0].ft
  local parser_name = lang

  local parser_ok, parser = pcall(vim.treesitter.get_parser, 0, parser_name)

  if parser_ok then
    local trees = parser:parse()
    local root = trees[1]:root()

    return parser_name, root
  end
end

local get_visual_bound_lines = function()
  local vstart = vim.fn.getpos('v')[2]
  local vend = vim.fn.getpos('.')[2]
  if vstart < vend then
    return vstart, vend
  else
    return vend, vstart
  end
end

local query_visual_selection = function(query)
  local parser_name, root = get_parser_name_and_root()
  local rc = {}
  local cquery = vim.treesitter.query.parse(parser_name, query)
  local vstart, vend = get_visual_bound_lines()
  for _, match, _ in cquery:iter_matches(root, 0, vstart, vend, { all = true }) do
    for id, nodes in pairs(match) do
      table.insert(rc, {
        capture = cquery.captures[id],
        nodes = nodes,
      })
    end
  end
  return rc
end

QueryArgs = function()
  local function_params_query = [[
  ; query
(binary_operator
  lhs: (identifier) @fn
  rhs: (function_definition
    parameters: (parameters
      parameter: (parameter
        name: (identifier) @param
      )
    )
  )
)
]]
  local fn_line
  local fn_name
  local fn_args = {}
  matches = query_visual_selection(function_params_query)
  for i, rc in ipairs(matches) do
    local capture = rc.capture
    local nodes = rc.nodes

    vim.print("capture: " .. capture)
    vim.print(nodes)
  end
end


vim.api.nvim_set_keymap("v", "<enter>", "<cmd>:lua QueryArgs()<CR>", {})
