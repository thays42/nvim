-- Reserve space in the gutter
vim.opt.signcolumn = 'yes'

-- This is where you enable features that only work
-- if there is a language server active in the file
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({ 'n', 'x' }, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

local allow_format = function(servers)
  return function(client) return vim.tbl_contains(servers, client.name) end
end

local buffer_autoformat = function(bufnr)
  local group = 'lsp_autoformat'
  vim.api.nvim_create_augroup(group, { clear = false })
  vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = bufnr,
    group = group,
    desc = 'LSP format on save',
    callback = function()
      -- note: do not enable async formatting
      vim.lsp.buf.format({ async = false, timeout_ms = 10000, filter = allow_format({ 'lua_ls', 'gopls' }) })
    end,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)
    if client == nil then
      return
    end

    if client.supports_method('textDocument/formatting') then
      buffer_autoformat(event.buf)
    end

    local opts = { buffer = event.buf }
    vim.keymap.set({ 'n', 'x' }, 'gq', function()
      vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
    end, opts)
  end
})

-- Language Server Setup
local lspconfig = require("lspconfig")

local is_executable = vim.fn.executable
local servers = {}

if is_executable("lua-language-server") == 1 then
  servers.lua_ls = {}
end

if is_executable("gopls") == 1 then
  servers.gopls = {}
end

if is_executable("ruff") == 1 then
  servers.ruff = {}
end

if is_executable("docker-langserver") == 1 then
  servers.dockerls = {}
end

if is_executable("docker-compose-langserver") == 1 then
  servers.docker_compose_language_service = {}
end

for server, config in pairs(servers) do
  config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
  lspconfig[server].setup(config)
end
