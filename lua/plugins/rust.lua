-- Rust tooling
--
-- rustaceanvim manages rust-analyzer itself (runnables, debuggables, macro
-- expansion, DAP). Do NOT also configure rust_analyzer in lua/lsp/servers.lua --
-- starting it twice conflicts.
--
-- Toolchain (via rustup): rustc, cargo, rustfmt, rust-analyzer
-- Formatting: rustfmt via conform.nvim (see completion.lua)
-- Debugging: lldb-dap (install with: sudo dnf install lldb)

return {
  -- rust-analyzer wrapper with extra Rust-specific goodies
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- v6 requires Neovim 0.12
    lazy = false, -- the plugin handles its own lazy-loading on the rust filetype
    init = function()
      -- Compat shim: rustaceanvim 6.9.7's server_status.lua still calls the
      -- deprecated vim.lsp.get_buffers_by_client_id() (slated for removal in
      -- nvim 0.13), which prints a once-per-session warning. Reimplement it
      -- exactly as nvim core does, minus the deprecation notice. Also keeps the
      -- call working when 0.13 removes the original. Remove once rustaceanvim
      -- migrates to vim.lsp.get_client_by_id(id).attached_buffers.
      vim.lsp.get_buffers_by_client_id = function(client_id)
        local client = vim.lsp.get_client_by_id(client_id)
        return client and vim.tbl_keys(client.attached_buffers) or {}
      end

      local ok_blink, blink = pcall(require, 'blink.cmp')

      vim.g.rustaceanvim = {
        server = {
          -- Match the completion capabilities used by every other server
          capabilities = ok_blink and blink.get_lsp_capabilities() or nil,

          -- Ported from the old rust_analyzer block in lua/lsp/servers.lua
          default_settings = {
            ['rust-analyzer'] = {
              check = { command = 'clippy' },
              cargo = { allFeatures = true },
            },
          },

          on_attach = function(_, bufnr)
            local map = function(keys, fn, desc, mode)
              vim.keymap.set(mode or 'n', keys, fn, { buffer = bufnr, desc = 'Rust: ' .. desc })
            end

            -- Rust-specific actions, grouped under <leader>R ([R]ust)
            map('<leader>Rr', function()
              vim.cmd.RustLsp 'runnables'
            end, '[R]unnables')
            map('<leader>Rd', function()
              vim.cmd.RustLsp 'debuggables'
            end, '[D]ebuggables')
            map('<leader>Rm', function()
              vim.cmd.RustLsp 'expandMacro'
            end, 'Expand [m]acro')
            map('<leader>Re', function()
              vim.cmd.RustLsp 'explainError'
            end, 'Explain [e]rror')
            map('<leader>Rc', function()
              vim.cmd.RustLsp 'openCargo'
            end, 'Open [C]argo.toml')
            map('<leader>Rp', function()
              vim.cmd.RustLsp 'parentModule'
            end, '[P]arent module')

            -- Override the generic LSP defaults with rustaceanvim's richer versions.
            -- Scheduled so we win over the global LspAttach handler (lua/lsp/init.lua)
            -- and Neovim's built-in K mapping, whichever attaches last.
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(bufnr) then
                return
              end
              map('K', function()
                vim.cmd.RustLsp { 'hover', 'actions' }
              end, 'Hover actions')
              map('gra', function()
                vim.cmd.RustLsp 'codeAction'
              end, 'Code action', { 'n', 'x' })
            end)

            local ok, wk = pcall(require, 'which-key')
            if ok then
              wk.add { { '<leader>R', group = '[R]ust', buffer = bufnr } }
            end
          end,
        },

        -- Debugging via lldb-dap (LLVM's DAP adapter, from the `lldb` package).
        -- rustaceanvim builds the launch config; your <leader>d* keymaps drive it.
        dap = {
          adapter = {
            type = 'executable',
            command = 'lldb-dap',
            name = 'lldb',
          },
        },
      }
    end,
  },

  -- Cargo.toml dependency management: version completion + "newer version" hints.
  -- crates.nvim runs an in-process LSP; its completion/hover/actions flow through
  -- the existing blink `lsp` source and the standard LSP keymaps -- no extra
  -- blink provider needed.
  {
    'saecki/crates.nvim',
    tag = 'stable',
    event = { 'BufRead Cargo.toml' },
    opts = {
      lsp = {
        enabled = true,
        actions = true,
        completion = true,
        hover = true,
      },
    },
  },
}
