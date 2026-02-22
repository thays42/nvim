return {
  -- R.nvim for interactive R development
  {
    'R-nvim/R.nvim',
    lazy = false,
    config = function()
      -- ========================================================================
      -- R.nvim Configuration
      -- ========================================================================
      -- Uncomment commands in disable_cmds to disable default keybindings
      -- Then add your own custom mappings below

      local opts = {
        -- Use radian instead of standard R console
        -- radian provides syntax highlighting, multiline editing, and vi mode
        R_app = 'radian',
        R_cmd = 'R',
        R_args = {},
        bracketed_paste = true,

        min_editor_width = 72,
        rconsole_width = 78,

        -- Use Neovim's built-in terminal (better integration with nvim-dap and R.nvim)
        -- external_term is not set, so R.nvim uses Neovim terminal by default

        -- Data frame viewer: use csvlens (Rust-based CSV viewer)
        -- Data flow: R saves df to temp TSV file -> csvlens opens it in terminal
        view_df = {
          open_app = 'terminal:csvlens',
          csv_sep = '\t',
          -- Use data.table::fwrite() for faster export of large data frames
          save_fun = "function(obj, obj_name) { f <- paste0(tempdir(), '/', obj_name, '.tsv'); data.table::fwrite(obj, f, sep = '\t'); f }",
        },

        -- Disable default commands (uncomment to disable specific commands)
        -- This allows you to selectively re-enable and remap only what you need
        disable_cmds = {
          -- Start/Stop R Console
          -- 'RStart',           -- <LocalLeader>rf
          -- 'RCustomStart',     -- <LocalLeader>rc
          -- 'RClose',           -- <LocalLeader>rq
          -- 'RSaveClose',       -- <LocalLeader>rw

          -- Send Code (most of these you probably don't need)
          -- 'RSendLine',        -- <LocalLeader>l
          -- 'RDSendLine',       -- <LocalLeader>d
          -- 'RSendSelection',   -- <LocalLeader>ss
          -- 'RDSendSelection',  -- <LocalLeader>sd
          'RSendParagraph', -- <LocalLeader>pp (disable - rarely used)
          'RDSendParagraph', -- <LocalLeader>pd (disable - rarely used)
          'RSendChain', -- <LocalLeader>sc (disable unless you use pipes heavily)
          'RSendCurrentFun', -- <LocalLeader>fc
          'RDSendCurrentFun', -- <LocalLeader>fd
          'RSendAllFun', -- <LocalLeader>fa (disable - rarely needed)
          'RSendFile', -- <LocalLeader>aa (disable - rarely used)
          'RSendAboveLines', -- <LocalLeader>su (disable - rarely used)
          'RSendMotion', -- <LocalLeader>m (disable - complex)
          'RSendMBlock', -- <LocalLeader>bb (disable - rarely used)
          'RDSendMBlock', -- <LocalLeader>bd (disable - rarely used)
          'RNLeftPart', -- <LocalLeader>r<left> (disable)
          'RNRightPart', -- <LocalLeader>r<right> (disable)
          'RILeftPart', -- Insert mode (disable)
          'RIRightPart', -- Insert mode (disable)
          'RSendLAndOpenNewOne', -- (disable - confusing)
          'RInsertLineOutput', -- <LocalLeader>o (disable - rarely used)

          -- Chunk operations (only useful for Rmd/Quarto)
          'RSendChunk',
          'RDSendChunk',
          'RSendChunkFH',
          'RNextRChunk',
          'RPreviousRChunk',

          -- R CMD operations (most people use devtools instead)
          'RShowRout', -- <LocalLeader>ao

          -- Knit/Weave (if you don't use Rmd/Rnw)
          'RKnit',
          'RMakeHTML',
          'RMakeODT',
          'RMakePDF',
          'RMakePDFK',
          'RMakePDFKb',
          'RMakeRmd',
          'RMakeAll',
          'RMakeWord',
          'RSweave',
          'RBibTeX',
          'RBibTeXK',
          'RKnitRmCache',

          -- Quarto (if you don't use Quarto)
          'RQuartoRender',
          'RQuartoPreview',
          'RQuartoStop',

          -- LaTeX operations (if you don't use Rnw)
          'RGoToTeX',
          'RSyncFor',
          'ROpenPDF',

          -- Insert operations (some are useful, keep what you like)
          -- 'RInsertAssign',    -- Alt+- for <-
          'RInsertPipe', -- <LocalLeader>, for |> (use snippets instead)
          'RmdInsertChunk',
          'RnwInsertChunk',

          -- Format operations (rarely used)
          'RFormatNumbers', -- <LocalLeader>cn
          'RFormatSubsetting', -- <LocalLeader>cs
          'RSeparatePath', -- <LocalLeader>sp

          -- Commands (keep the useful ones)
          -- 'RHelp',            -- <LocalLeader>rh
          -- 'RObjectPr',        -- <LocalLeader>rp
          -- 'RObjectStr',       -- <LocalLeader>rt
          -- 'RSummary',         -- <LocalLeader>rs
          -- 'RPlot',            -- <LocalLeader>rg
          'RSPlot', -- <LocalLeader>rb (disable - redundant)
          'RShowArgs', -- <LocalLeader>ra (disable - LSP shows this)
          'RObjectNames', -- <LocalLeader>rn (disable - rarely used)
          'RListSpace', -- <LocalLeader>rl (disable - use object browser)
          'RClearAll', -- <LocalLeader>rm (dangerous - disable)
          'RClearConsole', -- <LocalLeader>rr (disable - Ctrl+L works)
          'RSetwd', -- <LocalLeader>rd (disable - use .Rproj)

          -- Debug operations
          -- 'RDebug',              -- <LocalLeader>bg
          -- 'RUndebug',            -- <LocalLeader>ud

          -- Data viewing (keep if useful)
          -- 'RViewDF',          -- <LocalLeader>rv
          'RDputObj', -- <LocalLeader>td (disable - rarely used)
          'RShowEx', -- <LocalLeader>re (disable - rarely used)

          -- Object Browser
          -- 'ROBToggle',        -- <LocalLeader>ro
          'ROBOpenLists', -- <LocalLeader>r= (disable - object browser does this)
          'ROBCloseLists', -- <LocalLeader>r- (disable - object browser does this)

          -- Package operations (disable - use custom devtools commands below)
          'RPackages', -- <LocalLeader>ip
        },

        -- Object browser mappings
        objbr_mappings = {
          c = 'class',
          ['<localleader>gg'] = 'head({object}, n = 15)',
          ['<localleader>gt'] = 'tail({object}, n = 15)',
          v = 'View({object})',
          s = 'str({object})',
          ['<localleader>p'] = 'print({object})',
        },
      }

      require('r').setup(opts)

      -- Auto-close csvlens terminal when it exits successfully
      vim.api.nvim_create_autocmd('TermClose', {
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)
          if bufname:match 'csvlens' and vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(args.buf, { force = true })
          end
        end,
      })

      -- ========================================================================
      -- Custom Keybindings
      -- ========================================================================
      -- Add/remove/modify keybindings here

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'r',
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          local function rmap(keys, cmd, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, cmd, { buffer = bufnr, desc = 'R: ' .. desc })
          end

          -- ====================================================================
          -- Core Workflow Keybindings
          -- ====================================================================

          -- Send code (most important - use Enter for quick workflow)
          rmap('<CR>', '<Plug>RDSendLine', 'Send line and move down')
          rmap('<CR>', '<Plug>RSendSelection', 'Send selection', 'v')

          -- Alternative send methods (uncomment if you want them)
          -- rmap('<localleader>l', '<Plug>RSendLine', 'Send line (no move)')
          -- rmap('<localleader>p', '<Plug>RSendParagraph', 'Send paragraph')
          -- rmap('<localleader>f', '<Plug>RSendCurrentFun', 'Send function')
          -- rmap('<localleader>c', '<Plug>RSendChain', 'Send pipe chain')

          -- Console management
          rmap('<localleader>rf', '<Plug>RStart', 'Start R console')
          rmap('<localleader>rq', '<Plug>RClose', 'Quit R console')

          -- Object browser & help
          rmap('<localleader>ro', '<Plug>ROBToggle', 'Toggle object browser')
          rmap('<localleader>rh', '<Plug>RHelp', 'R help on word')

          -- Quick inspect commands
          rmap('<localleader>rp', '<Plug>RObjectPr', 'print()')
          -- rmap('<localleader>rt', '<Plug>RObjectStr', 'str()')
          -- rmap('<localleader>rs', '<Plug>RSummary', 'summary()')
          rmap('<localleader>rv', '<Plug>RViewDF', 'View() data frame')

          -- ====================================================================
          -- Debugging with browser()
          -- ====================================================================
          -- R doesn't have a working DAP adapter for nvim-dap (see debug.lua)
          -- Use browser()-based debugging instead

          rmap('<localleader>bg', '<Plug>RDebug', 'debug() function')
          rmap('<localleader>ud', '<Plug>RUndebug', 'undebug() function')

          -- Debug frame inspection (use when inside browser())
          rmap('<localleader>dl', function()
            require('r.send').cmd 'ls()'
          end, 'List variables in current frame')

          rmap('<localleader>de', function()
            require('r.send').cmd 'ls.str()'
          end, 'List variables with structure')

          rmap('<localleader>dw', function()
            require('r.send').cmd 'where'
          end, 'Show call stack')

          -- ====================================================================
          -- Package Development (devtools)
          -- ====================================================================

          rmap('<localleader>rT', function()
            require('r.send').cmd 'devtools::test()'
          end, 'devtools::test()')

          rmap('<localleader>rt', function()
            local file = vim.fn.expand '%:t:r'
            require('r.send').cmd('devtools::test_file("' .. file .. '")')
          end, 'devtools::test_file()')

          rmap('<localleader>rd', function()
            require('r.send').cmd 'devtools::document()'
          end, 'devtools::document()')

          rmap('<localleader>rl', function()
            require('r.send').cmd 'devtools::load_all()'
          end, 'devtools::load_all()')

          -- ====================================================================
          -- Optional: Rmd/Quarto (uncomment if you use them)
          -- ====================================================================

          -- rmap('<localleader>kk', '<Plug>RKnit', 'Knit document')
          -- rmap('<localleader>kp', '<Plug>RMakePDFK', 'Knit to PDF')
          -- rmap('<localleader>kh', '<Plug>RMakeHTML', 'Knit to HTML')
        end,
      })

      -- Which-key groups
      local ok, wk = pcall(require, 'which-key')
      if ok then
        wk.add {
          { '<localleader>r', group = '[R] Commands' },
          { '<localleader>d', group = '[R] Debug' },
          { '<localleader>b', group = '[R] Browser Debug' },
        }
      end
    end,
  },

  -- Note: Completions come from the R language server via blink.cmp's LSP source
  -- cmp-r is for nvim-cmp only, not needed with blink.cmp
}
