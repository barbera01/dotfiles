return {
  {
    "xiyaowong/nvim-transparent",
    config = function()
      require("transparent").setup({
        enable = true,  -- Enable transparency
        extra_groups = {  -- Groups to make transparent
          "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
          "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
          "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
          "SignColumn", "CursorLineNr", "EndOfBuffer"
        },
        exclude = {}  -- Exclude groups from transparency if needed
      })
    end
  }
}
