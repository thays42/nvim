return {
  -- Neotest: test runner framework
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- Using local adapter in lua/neotest-testthat/ (upstream is abandoned)
    },
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run()
        end,
        desc = '[T]est: Run nearest [T]est',
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
      require('neotest').setup {
        adapters = {
          require 'neotest-testthat',
        },
        -- Show test output on failure
        output = { open_on_run = 'short' },
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
