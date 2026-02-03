return {
  {
    "james-t-larson/posting.nvim",
    config = function()
      local posting = require("posting")

      -- Fullscreen-style float like lazygit/lazydocker integrations.
      -- posting.nvim's internal window geometry can't reach true fullscreen
      -- due to its row calculation, so we patch window placement for posting
      -- buffers only.
      local orig_open_win = vim.g._posting_orig_open_win or vim.api.nvim_open_win

      local function is_posting_buf(buf)
        local name = vim.api.nvim_buf_get_name(buf)
        return type(name) == "string" and name:match("^posting%s") ~= nil
      end

      local function fullscreen_cfg(cfg)
        local columns = vim.o.columns
        local lines = vim.o.lines
        cfg.relative = "editor"
        cfg.style = "minimal"
        cfg.border = "none"
        cfg.col = 0
        cfg.row = 0
        cfg.width = columns
        cfg.height = math.max(1, lines - 2)
        return cfg
      end

      if not vim.g._posting_open_win_patched then
        vim.g._posting_open_win_patched = true
        vim.g._posting_orig_open_win = orig_open_win

        vim.api.nvim_open_win = function(buf, enter, cfg)
          if is_posting_buf(buf) then
            cfg = fullscreen_cfg(cfg or {})
          end
          return orig_open_win(buf, enter, cfg)
        end
      end

      local function resize_posting_wins()
        local columns = vim.o.columns
        local lines = vim.o.lines
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_posting_buf(buf) then
            pcall(vim.api.nvim_win_set_config, win, {
              relative = "editor",
              col = 0,
              row = 0,
              width = columns,
              height = math.max(1, lines - 2),
            })
          end
        end
      end

      vim.api.nvim_create_autocmd("VimResized", { callback = resize_posting_wins })

      local function default_collection_dir()
        return vim.env.POSTING_COLLECTION_DIR or "/home/andy/repos/aba-sorted-github/Posting-Collections"
      end

      local posting_collection = vim.g.posting_collection
      local env_by_collection = vim.g.posting_env_by_collection or {}
      vim.g.posting_env_by_collection = env_by_collection

      local uv = vim.uv or vim.loop

      local function file_exists(path)
        return type(path) == "string" and path ~= "" and uv and uv.fs_stat(path) ~= nil
      end

      local function list_env_files(dir)
        local seen = {}
        local out = {}
        local patterns = {
          dir .. "/.env",
          dir .. "/.env.*",
          dir .. "/*.env",
          dir .. "/posting-envs/*.env",
          dir .. "/env/*.env",
        }

        for _, pat in ipairs(patterns) do
          local matches = vim.fn.glob(pat, 0, 1)
          for _, p in ipairs(matches) do
            if not seen[p] and file_exists(p) then
              seen[p] = true
              table.insert(out, p)
            end
          end
        end

        table.sort(out)
        return out
      end

      local function posting_close_all()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          if is_posting_buf(buf) then
            local ok, job_id = pcall(function()
              return vim.b[buf].terminal_job_id
            end)
            if ok and type(job_id) == "number" and job_id ~= 0 then
              pcall(vim.fn.jobstop, job_id)
            end

            pcall(vim.api.nvim_win_close, win, true)
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
        end
      end

      vim.api.nvim_create_user_command("PostingClose", posting_close_all, { desc = "Close Posting and stop job" })

      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function(ev)
          if not is_posting_buf(ev.buf) then
            return
          end
          local opts = { noremap = true, silent = true, buffer = ev.buf }
          vim.keymap.set("t", "q", [[<C-\><C-n>:PostingClose<CR>]], opts)
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>:PostingClose<CR>]], opts)
          vim.keymap.set("t", "<C-q>", [[<C-\><C-n>:PostingClose<CR>]], opts)
          -- <C-c> is often captured by the terminal job; keep as best-effort.
          vim.keymap.set("t", "<C-c>", [[<C-\><C-n>:PostingClose<CR>]], opts)
        end,
      })

      local function pick_collection(cb)
        local cwd = vim.fn.getcwd()
        local default_path = default_collection_dir()

        local items = {}
        table.insert(items, { label = "Default: " .. default_path, value = default_path })
        table.insert(items, { label = "CWD: " .. cwd, value = cwd })

        vim.ui.select(items, {
          prompt = "Posting collection",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          -- If you cancel the picker, fall back to the default dir.
          cb((choice and choice.value) or default_path)
        end)
      end

      local function pick_env(collection_dir, cb)
        local env_files = list_env_files(collection_dir)
        if #env_files == 0 then
          vim.notify("No env files found in: " .. collection_dir, vim.log.levels.INFO)
          cb(nil)
          return
        end

        vim.notify("Select Posting env (" .. tostring(#env_files) .. " found)", vim.log.levels.INFO)

        local items = { { label = "No env", value = nil } }
        for _, p in ipairs(env_files) do
          local name = vim.fn.fnamemodify(p, ":t")
          table.insert(items, { label = name, value = p })
        end

        vim.ui.select(items, {
          prompt = "Posting env",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          cb(choice and choice.value or nil)
        end)
      end

      vim.api.nvim_create_user_command("PostingEnv", function(cmd)
        local extra_args = cmd.args or ""
        if cmd.bang then
          posting_collection = nil
        end

        local function open_with_collection(path)
          posting_collection = path
          vim.g.posting_collection = posting_collection

          pick_env(posting_collection, function(env_path)
            if env_path ~= nil then
              env_by_collection[posting_collection] = env_path
            end

            local args = "--collection " .. posting_collection
            if env_path and env_path ~= "" then
              args = args .. " --env " .. env_path
            end
            if extra_args ~= "" then
              args = args .. " " .. extra_args
            end

            vim.cmd("OpenPosting " .. args)
          end)
        end

        if not posting_collection or posting_collection == "" then
          pick_collection(open_with_collection)
          return
        end

        open_with_collection(posting_collection)
      end, {
        nargs = "*",
        bang = true,
        desc = "Pick env for Posting then open",
      })

      local force_pick_env = false

      vim.api.nvim_create_user_command("Posting", function(cmd)
        local extra_args = cmd.args or ""
        local reload = cmd.bang == true
        if reload then
          posting_collection = nil
        end

        local function open_with_collection(path)
          posting_collection = path
          vim.g.posting_collection = posting_collection

          -- If user explicitly passes --env, don't interfere.
          local user_specified_env = extra_args:match("%-%-env%s+%S+") ~= nil

          -- Note: posting.nvim's arg parsing doesn't handle spaces in paths.
          local function open_now(env_path)
            if env_path ~= nil then
              env_by_collection[posting_collection] = env_path
            end

            local args = "--collection " .. posting_collection
            if env_path and env_path ~= "" then
              args = args .. " --env " .. env_path
            end
            if extra_args ~= "" then
              args = args .. " " .. extra_args
            end

            vim.cmd("OpenPosting " .. args)
          end

          if user_specified_env then
            open_now(nil)
            return
          end

          local cached_env = env_by_collection[posting_collection]
          if cached_env and cached_env ~= "" and not file_exists(cached_env) then
            cached_env = nil
            env_by_collection[posting_collection] = nil
          end

          if cached_env and not reload and not force_pick_env then
            open_now(cached_env)
            return
          end

          pick_env(posting_collection, open_now)
          force_pick_env = false
        end

        if not posting_collection or posting_collection == "" then
          pick_collection(open_with_collection)
          return
        end

        open_with_collection(posting_collection)
      end, {
        nargs = "*",
        bang = true,
        desc = "Open Posting",
      })

      vim.api.nvim_create_user_command("PostingReload", function(cmd)
        force_pick_env = true
        posting_collection = nil
        local args = cmd.args or ""
        if args ~= "" then
          vim.cmd("Posting " .. args)
        else
          vim.cmd("Posting")
        end
      end, { nargs = "*", desc = "Re-pick collection/env then open Posting" })

      posting.setup({
        keybinds = {
          {
            binding = "<leader>po",
            command = ":Posting<CR>",
            desc = "Open Posting",
          },
        },
        ui = {
          border = "none",
          width = 0.95,
          height = 0.87,
          x = 0.5,
          y = 0.5,
        },
      })

      -- Prefer the wrapper so collection/env comes from your shell config.
      vim.keymap.set("n", "<leader>p", ":Posting<CR>", { silent = true, desc = "Open Posting" })
    end,
  },
}
