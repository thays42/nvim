return {
  -- Neotest: test runner framework
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Using local adapter in lua/neotest-testthat/ (upstream is abandoned)
      'MisanthropicBit/neotest-busted', -- Lua/busted specs (runs through nvim = luajit)
    },
    keys = {
      {
        '<leader>tt',
        function()
          -- Context-aware: in a spec/test buffer, run the nearest test (the
          -- single `it` under the cursor). Anywhere else (e.g. solution.lua,
          -- which has no test positions so plain run-nearest would do nothing),
          -- run every test in the file's directory -- which finds and runs the
          -- sibling *_spec.lua.
          local name = vim.fn.expand '%:t'
          local is_test = name:match '_spec%.' or name:match '_test%.' or name:match '^test[-_]'
          if is_test then
            require('neotest').run.run()
          else
            require('neotest').run.run(vim.fn.expand '%:p:h')
          end
        end,
        desc = '[T]est: Run nearest [T]est (or folder from non-spec)',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = '[T]est: Run [F]ile',
      },
      {
        '<leader>ta',
        function()
          require('neotest').run.run(vim.fn.getcwd())
        end,
        desc = '[T]est: Run [A]ll',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = '[T]est: Toggle [S]ummary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open { enter = true }
        end,
        desc = '[T]est: Show [O]utput',
      },
      {
        '<leader>tO',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = '[T]est: Toggle [O]utput panel',
      },
      {
        '<leader>tw',
        function()
          require('neotest').watch.toggle(vim.fn.expand '%')
        end,
        desc = '[T]est: Toggle [W]atch mode',
      },
      {
        '<leader>tl',
        function()
          require('neotest').run.run_last()
        end,
        desc = '[T]est: Run [L]ast',
      },
    },
    config = function()
      -- Busted via nvim itself as the Lua interpreter (= luajit, matching
      -- love2d). local_luarocks_only=false so it finds the ~/.luarocks
      -- (--local) busted install.
      local busted_adapter = require 'neotest-busted' {
        local_luarocks_only = false,
        -- nvim IS luajit, so run busted in-process. Without this, busted re-execs
        -- to the standalone luajit binary (each exercise's `.busted` sets
        -- lua="luajit" for terminal/CLI use), and that re-exec fails to
        -- shell-quote `--filter` args containing spaces / ( ) / $ -- which breaks
        -- namespace & nearest runs with "Failed to generate neotest position id
        -- ... for test ''" spam. --ignore-lua skips the re-exec (dialect is
        -- unchanged: nvim's runtime already is luajit).
        busted_args = { '--ignore-lua' },
      }

      -- neotest runs busted from nvim's cwd and never injects the adapter root.
      -- Our exercises are self-contained (each ships its own .busted and a bare
      -- require("solution")), so pin cwd to the spec file's own directory --
      -- otherwise require("solution") fails whenever nvim's cwd isn't the
      -- exercise dir. (Verified: repo-root cwd fails, exercise-dir cwd passes.)
      local build_spec = busted_adapter.build_spec
      busted_adapter.build_spec = function(args)
        local spec = build_spec(args)
        if spec and args and args.tree then
          local path = args.tree:data().path
          local cwd = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
          if spec.command then
            spec.cwd = cwd
          else
            for _, s in ipairs(spec) do
              s.cwd = cwd
            end
          end
        end
        return spec
      end

      -- Custom consumer: emit a one-line pass/fail summary to :messages on each
      -- run, instead of auto-popping the output float. Full detail is still a
      -- keypress away via <leader>to (neotest.output.open) on the same results.
      -- Only test-type positions are counted -- the run's file/dir aggregates
      -- also carry a status and would otherwise inflate the totals.
      local function notify_summary(client)
        client.listeners.results = function(adapter_id, results, partial)
          if partial then
            return -- wait for the final, complete result set
          end
          local passed, failed, skipped, total = 0, 0, 0, 0
          for pos_id, result in pairs(results) do
            local ok, node = pcall(client.get_position, client, pos_id, { adapter = adapter_id })
            if ok and node and node:data().type == 'test' then
              total = total + 1
              if result.status == 'passed' then
                passed = passed + 1
              elseif result.status == 'failed' then
                failed = failed + 1
              elseif result.status == 'skipped' then
                skipped = skipped + 1
              end
            end
          end
          if total == 0 then
            return
          end
          local msg = string.format('%s %d/%d passed', failed > 0 and '✗' or '✓', passed, total)
          if failed > 0 then
            msg = msg .. string.format(' — %d failed (<leader>tO for detail)', failed)
          end
          if skipped > 0 then
            msg = msg .. string.format(', %d skipped', skipped)
          end
          local level = failed > 0 and vim.log.levels.ERROR or vim.log.levels.INFO
          vim.schedule(function()
            vim.notify(msg, level)
          end)
        end
      end

      require('neotest').setup {
        adapters = {
          require 'neotest-testthat',
          busted_adapter,
        },
        consumers = { notify_summary = notify_summary },
        -- Don't auto-pop the output float; the notify_summary consumer prints a
        -- one-line result to :messages instead. <leader>to opens full detail.
        output = { open_on_run = false },
        -- Status signs in the sign column
        status = { virtual_text = true },
        -- Diagnostics for failed tests
        diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
      }

      -- Which-key group
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add {
          { '<leader>t', group = '[T]ests' },
        }
      end
    end,
  },

  -- nvim-coverage: display coverage in sign column
  {
    'andythigpen/nvim-coverage',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = { 'Coverage', 'CoverageLoad', 'CoverageShow', 'CoverageHide', 'CoverageToggle', 'CoverageSummary', 'CoverageClear' },
    keys = {
      {
        '<leader>tc',
        function()
          local coverage = require 'coverage'
          -- Track if we've loaded coverage this session
          if not vim.g.coverage_loaded then
            coverage.load(true) -- load and show
            vim.g.coverage_loaded = true
          else
            coverage.toggle()
          end
        end,
        desc = '[T]est: Toggle [C]overage',
      },
      { '<leader>tC', '<cmd>CoverageSummary<cr>', desc = '[T]est: [C]overage summary' },
      {
        '<leader>tg',
        function()
          vim.notify('Generating coverage report...', vim.log.levels.INFO)
          -- Clear navigation cache so it picks up new data
          pcall(function()
            require('coverage-r.navigation').clear_cache()
          end)
          vim.system({ 'Rscript', '-e', 'covr::to_cobertura(covr::package_coverage(), "coverage.xml")' }, { cwd = vim.fn.getcwd() }, function(result)
            vim.schedule(function()
              if result.code == 0 then
                vim.notify('Coverage report generated: coverage.xml', vim.log.levels.INFO)
                -- Auto-reload if coverage is displayed
                pcall(function()
                  require('coverage').load(true)
                end)
              else
                vim.notify('Coverage generation failed:\n' .. (result.stderr or ''), vim.log.levels.ERROR)
              end
            end)
          end)
        end,
        desc = '[T]est: [G]enerate coverage',
      },
      {
        ']u',
        function()
          require('coverage-r.navigation').next_uncovered()
        end,
        desc = 'Next uncovered line',
      },
      {
        '[u',
        function()
          require('coverage-r.navigation').prev_uncovered()
        end,
        desc = 'Previous uncovered line',
      },
      {
        '<leader>tu',
        function()
          require('coverage-r.picker').pick()
        end,
        desc = '[T]est: [U]ncovered functions',
      },
    },
    opts = {
      auto_reload = true,
      lang = {
        r = {
          coverage_file = 'coverage.xml',
        },
      },
    },
    config = function(_, opts)
      -- Pre-register our R language module so nvim-coverage can find it
      package.loaded['coverage.languages.r'] = require 'coverage-r'

      require('coverage').setup(opts)
    end,
  },
}
