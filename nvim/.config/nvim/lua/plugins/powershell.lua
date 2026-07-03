-- PowerShell LSP + debugging via powershell.nvim.
--
-- Why not a plain PSES dap adapter: PSES started with -DebugServiceOnly has
-- no console, so scripts can never be interactive (Read-Host has nowhere to
-- read from; Write-Host only reaches the repl log). powershell.nvim starts
-- PSES with -EnableConsoleRepl inside a real terminal buffer (the equivalent
-- of VS Code's "PowerShell Integrated Console") and registers the nvim-dap
-- adapter ("ps1") plus launch/attach configurations itself. The debug
-- terminal is surfaced at the standard bottom slot by the ps1 listener in
-- lua/config/debugging.lua.
--
-- NOTE: this replaces the lspconfig powershell_es server (disabled in
-- lua/config/lsp-config.lua) — otherwise two PSES instances fight over the
-- same buffers. Bundle comes from mason (ensure_installed in
-- lua/plugins/mason-custom.lua).
return {
  "TheLeoP/powershell.nvim",
  ft = "ps1",
  opts = {
    bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
    -- Wrapper that strips -NonInteractive: pwsh >= 7.4 otherwise refuses
    -- Read-Host inside the console REPL, killing interactive debugging.
    -- See scripts/pwsh-interactive for details.
    shell = vim.fn.stdpath("config") .. "/scripts/pwsh-interactive",
    settings = {
      powershell = {
        codeFormatting = { preset = "OTBS" },
      },
    },
  },
}
