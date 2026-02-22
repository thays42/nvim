return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Debug UI
    {
      'rcarriga/nvim-dap-ui',
      dependencies = { 'nvim-neotest/nvim-nio' },
      opts = {},
      config = function(_, opts)
        local dap = require 'dap'
        local dapui = require 'dapui'
        dapui.setup(opts)
        dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        dap.listeners.before.event_exited['dapui_config'] = dapui.close
      end,
    },

    -- Virtual text for variable values
    { 'theHamsta/nvim-dap-virtual-text', opts = {} },

    -- Go debugging (requires delve: go install github.com/go-delve/delve/cmd/dlv@latest)
    {
      'leoluz/nvim-dap-go',
      opts = {},
    },
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: Start/[C]ontinue' },
    { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
    { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
    { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug: Step [O]ut' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
    { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = '[D]ebug: Set Conditional [B]reakpoint' },
    { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: Run [L]ast' },
    { '<leader>dr', function() require('dap').repl.open() end, desc = '[D]ebug: Open [R]EPL' },
    { '<leader>du', function() require('dapui').toggle() end, desc = '[D]ebug: Toggle [U]I' },
    { '<leader>dt', function() require('dap-go').debug_test() end, desc = '[D]ebug: Go [T]est' },
  },
  config = function()
    local dap = require 'dap'

    -- Signs
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition' })
    vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint' })
    vim.fn.sign_define('DapStopped', { text = '→', texthl = 'DapStopped', linehl = 'DapStopped' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '●', texthl = 'DapBreakpointRejected' })

    -- Highlight groups
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379', bg = '#2d3343' })

    -- ========================================================================
    -- R Debug Adapter (NOT CONFIGURED)
    --
    -- Attempted solutions:
    -- - debugadapter: Requires R-devel with browser hooks (too experimental)
    -- - vscDebugger: Designed for VS Code extension, doesn't work standalone
    --
    -- Current approach: Use browser() with R.nvim helpers
    -- See nvim/lua/plugins/r.lua for debug keybindings:
    -- - <LocalLeader>bg/ud: debug()/undebug()
    -- - <LocalLeader>dl: List variables in frame
    -- - <LocalLeader>de: List variables with structure
    -- - <LocalLeader>dw: Show call stack
    -- ========================================================================
  end,
}
