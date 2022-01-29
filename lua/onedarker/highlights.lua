local c = require "onedarker.colors"

local M = {}
local hl = { langs = {}, plugins = {} }

local highlight = vim.api.nvim_set_hl
local set_hl_ns = vim.api.nvim__set_hl_ns or vim.api.nvim_set_hl_ns
local create_namespace = vim.api.nvim_create_namespace

local function load_highlights(ns, highlights)
  for group_name, group_settings in pairs(highlights) do
    highlight(ns, group_name, group_settings)
  end
end

local function gui(group_settings)
  if group_settings.bold then
    return "bold"
  elseif group_settings.underline then
    return "underline"
  elseif group_settings.italic then
    return "italic"
  elseif group_settings.reverse then
    return "reverse"
  else
    return "NONE"
  end
end

local function vim_highlights(highlights)
  for group_name, group_settings in pairs(highlights) do
    local fg = group_settings.fg and "guifg=" .. group_settings.fg or "guifg=NONE"
    local bg = group_settings.bg and "guibg=" .. group_settings.bg or "guibg=NONE"
    vim.api.nvim_command("highlight " .. group_name .. " " .. "gui=" .. gui(group_settings) .. " " .. fg .. " " .. bg)
  end
end

local colors = {
  Fg = { fg = c.fg },
  Grey = { fg = c.grey },
  BrightGrey = { fg = c.bright_grey },
  Red = { fg = c.red },
  Cyan = { fg = c.cyan },
  Yellow = { fg = c.yellow },
  Orange = { fg = c.orange },
  Green = { fg = c.green },
  DarkGreen = { fg = c.dark_green },
  Blue = { fg = c.blue },
  Purple = { fg = c.purple },
  BrightYellow = { fg = c.bright_yellow },
  DarkCyan = { fg = c.dark_cyan },
}

hl.common = {
  Normal = { fg = c.fg, bg = c.bg0 },
  Terminal = { fg = c.fg, bg = c.bg0 },
  EndOfBuffer = { fg = c.bg0, bg = c.bg0 },
  FoldColumn = { fg = c.fg, bg = c.bg2 },
  Folded = { fg = c.fg, bg = c.bg2 },
  SignColumn = { fg = c.fg, bg = c.bg0 },
  ToolbarLine = { fg = c.fg },
  Cursor = { invert = true },
  vCursor = { bg = c.cursor },
  iCursor = { invert = true },
  lCursor = { bg = c.cursor },
  CursorIM = { invert = true },
  CursorColumn = { bg = c.bg1 },
  CursorLine = { bg = c.bg1 },
  ColorColumn = { bg = c.bg1 },
  CursorLineNr = { fg = c.fg },
  LineNr = { fg = c.grey },
  Conceal = { fg = c.grey, bg = c.bg1 },
  DiffAdd = { fg = c.none, bg = c.diff_add },
  DiffChange = { fg = c.none, bg = c.diff_change },
  DiffDelete = { fg = c.none, bg = c.diff_delete },
  DiffText = { fg = c.none, bg = c.diff_text },
  DiffAdded = colors.Green,
  DiffRemoved = colors.Red,
  DiffFile = colors.Cyan,
  DiffIndexLine = colors.Grey,
  Directory = { fg = c.blue },
  ErrorMsg = { fg = c.red, bold = true, bg = c.bg0 },
  WarningMsg = { fg = c.orange, bold = true, bg = c.bg0 },
  MoreMsg = { fg = c.cyan, bold = true, bg = c.bg0 },
  IncSearch = { bg = c.bg_d },
  Search = { bg = c.bg3 },
  MatchParen = { fg = c.blue, underline = true },
  NonText = { fg = c.grey },
  Whitespace = { fg = c.grey },
  ExtraWhitespace = { bg = c.dark_red },
  SpecialKey = { fg = c.grey },
  Pmenu = { fg = c.fg, bg = c.bg1 },
  PmenuSbar = { fg = c.none, bg = c.bg1 },
  PmenuSel = { fg = c.bg0, bg = c.bg_blue },
  WildMenu = { fg = c.bg0, bg = c.blue },
  PmenuThumb = { fg = c.none, bg = c.grey },
  Question = { fg = c.yellow },
  SpellBad = { fg = c.red, sp = c.red },
  SpellCap = { fg = c.yellow, sp = c.yellow },
  SpellLocal = { fg = c.blue, sp = c.blue },
  SpellRare = { fg = c.purple, sp = c.purple },
  StatusLine = { fg = c.fg, bg = c.bg1 },
  StatusLineTerm = { fg = c.bg0, bg = c.bg1 },
  StatusLineNC = { fg = c.grey, bg = c.bg2 },
  StatusLineTermNC = { fg = c.bg0, bg = c.bg2 },
  TabLine = { fg = c.fg, bg = c.bg1 },
  TabLineFill = { fg = c.grey, bg = c.bg0 },
  TabLineSel = { fg = c.fg, bg = c.bg0 },
  VertSplit = { fg = c.bg1 },
  Visual = { bg = c.bg2 },
  VisualNOS = { fg = c.none, bg = c.bg2 },
  QuickFixLine = { fg = c.blue },
  Debug = { fg = c.yellow },
  debugPC = { fg = c.bg0, bg = c.cyan },
  debugBreakpoint = { fg = c.bg0, bg = c.red },
  ToolbarButton = { fg = c.bg0, bg = c.bg_blue },
  MsgArea = { fg = c.fg, bg = c.bg },
  ModeMsg = { fg = c.fg, bg = c.bg },
  MsgSeparator = { fg = c.fg, bg = c.bg1 },
  NormalNC = { fg = c.fg, bg = c.bg },
  FloatBorder = { fg = c.gray, bg = c.bg1 },
  NormalFloat = { bg = c.bg1 },
  MatchWord = { style = "underline" },
  MatchWordCur = { style = "underline" },
  MatchParenCur = { style = "underline" },
  TermCursorNC = { bg = c.cursor },
  Title = { fg = c.blue, style = "bold" },
  Substitute = { fg = c.bg3, bg = c.orange },
  Variable = { fg = c.red },
  String = { fg = c.green },
  Character = { fg = c.green },
  Constant = { fg = c.yellow },
  Number = { fg = c.yellow },
  Boolean = { fg = c.orange },
  Float = { fg = c.yellow },
  Identifier = { fg = c.fg },
  Function = { fg = c.blue },
  Operator = { fg = c.purple },
  Type = { fg = c.yellow },
  StorageClass = { fg = c.cyan },
  Structure = { fg = c.purple },
  Typedef = { fg = c.yellow },
  Keyword = { fg = c.purple },
  Statement = { fg = c.purple },
  Conditional = { fg = c.purple },
  Repeat = { fg = c.purple },
  Label = { fg = c.blue },
  Exception = { fg = c.purple },
  Include = { fg = c.purple },
  PreProc = { fg = c.purple },
  Define = { fg = c.purple },
  Macro = { fg = c.purple },
  PreCondit = { fg = c.purple },
  Special = { fg = c.purple },
  SpecialChar = { fg = c.fg },
  Tag = { fg = c.blue },
  Delimiter = { fg = c.grey },
  SpecialComment = { fg = c.grey },
  Underlined = { style = "underline" },
  Bold = { style = "bold" },
  Italic = { style = "italic" },
  Ignore = { fg = c.cyan, bg = c.bg, style = "bold" },
  Todo = { fg = c.red, bg = c.bg, style = "bold" },
  Error = { fg = c.dark_red, bg = c.bg, style = "bold" },
}

hl.syntax = {
  String = colors.Green,
  Character = colors.Orange,
  confComment = colors.Grey,
  NormalFloat = { bg = c.bg1 },
  FloatBorder = { fg = c.grey },
  Number = colors.Orange,
  Float = colors.Orange,
  Boolean = colors.Orange,
  Type = colors.Yellow,
  Structure = colors.Yellow,
  StorageClass = colors.Yellow,
  Identifier = colors.Red,
  Constant = colors.Yellow,
  PreProc = colors.Purple,
  PreCondit = colors.Purple,
  Include = colors.Purple,
  Keyword = colors.Purple,
  Define = colors.Purple,
  Typedef = colors.Purple,
  Exception = colors.Purple,
  Conditional = colors.Purple,
  Repeat = colors.Purple,
  Statement = colors.Purple,
  Macro = colors.Red,
  Error = colors.Purple,
  Label = colors.Red,
  Special = colors.Red,
  SpecialChar = colors.Red,
  Function = colors.Blue,
  Operator = colors.Cyan,
  Title = colors.Cyan,
  Tag = colors.Green,
  Delimiter = colors.BrightGrey,
  Comment = { italic = true, fg = c.grey },
  SpecialComment = { italic = true, fg = c.grey },
  Todo = colors.Red,
}

hl.treesitter = {
  TSAnnotation = colors.Fg,
  TSAttribute = colors.Cyan,
  TSBoolean = colors.Orange,
  TSCharacter = colors.Fg,
  TSComment = { fg = c.grey, italic = true },
  TSConditional = colors.Purple,
  TSConstant = colors.Yellow,
  TSConstBuiltin = colors.Orange,
  TSConstMacro = colors.Orange,
  TSConstructor = colors.Yellow,
  TSError = colors.Fg,
  TSException = colors.Purple,
  TSField = colors.Red,
  TSFloat = colors.Green,
  TSFunction = colors.Blue,
  TSFuncBuiltin = colors.Cyan,
  TSFuncMacro = colors.Fg,
  TSInclude = colors.Purple,
  TSKeyword = colors.Purple,
  TSKeywordFunction = colors.yellow,
  TSKeywordOperator = colors.Purple,
  TSLabel = colors.Red,
  TSMethod = colors.Blue,
  TSNamespace = colors.Red,
  TSNone = colors.Fg,
  TSNumber = colors.Orange,
  TSOperator = colors.Cyan,
  TSParameter = colors.Red,
  TSParameterReference = colors.Fg,
  TSProperty = colors.Red,
  typescriptDecorator = colors.Fg,
  TSPunctDelimiter = colors.Fg,
  TSPunctBracket = colors.BrightYellow,
  TSPunctSpecial = colors.Purple,
  TSRepeat = colors.Purple,
  TSString = colors.Green,
  TSStringRegex = colors.Orange,
  TSStringEscape = colors.Red,
  TSSymbol = colors.Cyan,
  TSTag = colors.Red,
  TSTagDelimiter = colors.BrightGrey,
  TSText = colors.Fg,
  TSStrong = colors.Fg,
  TSEmphasis = colors.Fg,
  TSUnderline = colors.Fg,
  TSStrike = colors.Fg,
  TSTitle = colors.Fg,
  TSLiteral = colors.Green,
  TSURI = colors.Fg,
  TSMath = colors.Fg,
  TSTextReference = colors.Fg,
  TSEnviroment = colors.Fg,
  TSEnviromentName = colors.Fg,
  TSNote = colors.Fg,
  TSWarning = colors.Fg,
  TSDanger = colors.Fg,
  TSType = colors.Yellow,
  TSTypeBuiltin = colors.Yellow,
  TSVariable = colors.Red,
  TSVariableBuiltin = colors.Yellow,
  TSKeywordReturn = { fg = c.purple },
  TSTagAttribute = { fg = c.orange },
  TSQueryLinterError = { fg = c.orange },
  TSEnvironment = { fg = c.fg },
  TSEnvironmentName = { fg = c.fg },
  TSInlayHint = { italic = true, bg = c.bg1, fg = c.bg_d },
}

hl.plugins.lsp = {
  DiagnosticVirtualTextError = { fg = c.red },
  DiagnosticVirtualTextWarning = { fg = c.orange },
  DiagnosticVirtualTextInformation = { fg = c.dark_cyan },
  DiagnosticVirtualTextInfo = { fg = c.dark_cyan },
  DiagnosticVirtualTextHint = { fg = c.grey },
  DiagnosticSignError = { fg = c.red },
  DiagnosticSignWarn = { fg = c.orange },
  DiagnosticSignInfo = { fg = c.dark_cyan },
  DiagnosticSignHint = { fg = c.grey },
  DiagnosticFloatingError = { fg = c.red },
  DiagnosticFloatingWarn = { fg = c.orange },
  DiagnosticFloatingInfo = { fg = c.dark_cyan },
  DiagnosticFloatingHint = { fg = c.grey },
  DiagnosticError = { fg = c.red },
  DiagnosticWarning = { fg = c.orange },
  DiagnosticInformation = { fg = c.dark_cyan },
  DiagnosticHint = { fg = c.grey },
  LspDiagnosticsDefaultError = { fg = c.red },
  LspDiagnosticsDefaultHint = { fg = c.grey },
  LspDiagnosticsDefaultInformation = { fg = c.dark_cyan },
  LspDiagnosticsDefaultWarning = { fg = c.orange },
  LspDiagnosticsUnderlineError = { style = "underline" },
  LspDiagnosticsUnderlineHint = { style = "underline" },
  LspDiagnosticsUnderlineInformation = { style = "underline" },
  LspDiagnosticsUnderlineWarning = { style = "underline" },
  DiagnosticUnderlineError = { style = "underline" },
  DiagnosticUnderlineWarn = { style = "underline" },
  DiagnosticUnderlineInfo = { style = "underline" },
  DiagnosticUnderlineHint = { style = "underline" },
  LspDiagnosticsVirtualTextError = { fg = c.red },
  LspDiagnosticsVirtualTextWarning = { fg = c.orange },
  LspDiagnosticsVirtualTextInformation = { fg = c.dark_cyan },
  LspDiagnosticsVirtualTextHint = { fg = c.grey },
  LspReferenceText = { bg = c.bg1, style = "bold" },
  LspReferenceWrite = { bg = c.bg1, style = "bold" },
  LspReferenceRead = { bg = c.bg1, style = "bold" },
  LspDiagnosticsFloatingError = { fg = c.red },
  LspDiagnosticsFloatingWarning = { fg = c.orange },
  LspDiagnosticsFloatingInformation = { fg = c.dark_cyan },
  LspDiagnosticsFloatingHint = { fg = c.grey },
  LspDiagnosticsSignError = { fg = c.red },
  LspDiagnosticsSignWarning = { fg = c.orange },
  LspDiagnosticsSignInformation = { fg = c.dark_cyan },
  LspDiagnosticsSignHint = { fg = c.grey },
  LspDiagnosticsError = { fg = c.red },
  LspDiagnosticsWarning = { fg = c.orange },
  LspDiagnosticsInformation = { fg = c.dark_cyan },
  LspDiagnosticsHint = { fg = c.grey },
}

hl.plugins.whichkey = {
  WhichKey = colors.Red,
  WhichKeyDesc = colors.Blue,
  WhichKeyGroup = colors.Orange,
  WhichKeySeperator = colors.Green,
  WhichKeyFloat = { bg = c.bg1 },
}

hl.plugins.git = {
  SignAdd = colors.Green,
  SignChange = colors.Blue,
  SignDelete = colors.Red,
  GitSignsAdd = colors.Green,
  GitSignsChange = colors.Blue,
  GitSignsDelete = colors.Red,
}

hl.plugins.gitgutter = {
  GitGutterAdd = { fg = c.bright_green },
  GitGutterChange = { fg = c.bright_cyan },
  GitGutterDelete = { fg = c.bright_red },
}

hl.plugins.hop = {
  HopNextKey = { fg = c.bg0, bg = c.orange },
  HopNextKey1 = { fg = c.bg0, bg = c.orange },
  HopNextKey2 = { fg = c.bg0, bg = c.bg_yellow },
  HopUnmatched = {},
}

hl.plugins.indentblankline = { IndentBlankLineChar = { fg = c.bg3 }, IndentBlanklineContextChar = { fg = c.cursor } }

hl.plugins.diffview = {
  DiffviewFilePanelTitle = { fg = c.blue, bold = true },
  DiffviewFilePanelCounter = { fg = c.purple, bold = true },
  DiffviewFilePanelFileName = colors.Fg,
  DiffviewNormal = hl.common.Normal,
  DiffviewCursorLine = hl.common.CursorLine,
  DiffviewVertSplit = hl.common.VertSplit,
  DiffviewSignColumn = hl.common.SignColumn,
  DiffviewStatusLine = hl.common.StatusLine,
  DiffviewStatusLineNC = hl.common.StatusLineNC,
  DiffviewEndOfBuffer = hl.common.EndOfBuffer,
  DiffviewFilePanelRootPath = colors.Grey,
  DiffviewFilePanelPath = colors.Grey,
  DiffviewFilePanelInsertions = colors.Green,
  DiffviewFilePanelDeletions = colors.Red,
  DiffviewStatusAdded = colors.Green,
  DiffviewStatusUntracked = colors.Grey,
  DiffviewStatusModified = colors.Blue,
  DiffviewStatusRenamed = colors.Yellow,
  DiffviewStatusCopied = colors.BrightYellow,
  DiffviewStatusTypeChange = colors.Cyan,
  DiffviewStatusUnmerged = colors.Orange,
  DiffviewStatusUnknown = colors.Red,
  DiffviewStatusDeleted = colors.Red,
  DiffviewStatusBroken = colors.Red,
}

hl.plugins.gitsigns = {
  GitSignsAdd = colors.Green,
  GitSignsAddLn = colors.Green,
  GitSignsAddNr = colors.Green,
  GitSignsChange = colors.Blue,
  GitSignsChangeLn = colors.Blue,
  GitSignsChangeNr = colors.Blue,
  GitSignsDelete = colors.Red,
  GitSignsDeleteLn = colors.Red,
  GitSignsDeleteNr = colors.Red,
}

hl.plugins.nvim_tree = {
  NvimTreeNormal = { fg = c.fg, bg = c.bg0 },
  NvimTreeEndOfBuffer = { fg = c.bg0, bg = c.bg0 },
  NvimTreeRootFolder = { fg = c.purple, bold = true },
  NvimTreeGitDirty = colors.Orange,
  NvimTreeGitNew = colors.Green,
  NvimTreeGitDeleted = colors.Red,
  NvimTreeSpecialFile = { fg = c.yellow },
  NvimTreeIndentMarker = colors.Fg,
  NvimTreeImageFile = { fg = c.dark_purple },
  NvimTreeSymlink = colors.Purple,
  NvimTreeFolderName = colors.Blue,
}

hl.plugins.telescope = {
  TelescopeBorder = colors.Grey,
  TelescopeMatching = colors.Green,
  TelescopeNormal = { bg = c.bg, fg = c.fg },
  TelescopePromptPrefix = colors.Yellow,
  TelescopeSelection = { bg = c.bg2 },
  TelescopeSelectionCaret = colors.Yellow,
}

hl.plugins.dashboard = {
  DashboardShortcut = { fg = c.fg },
  DashboardHeader = colors.Orange,
  DashboardCenter = { fg = c.yellow },
  DashboardFooter = { fg = c.grey, bold = true },
}

hl.plugins.spectre = { SpectreChange = { fg = c.yellow }, SpectreDelete = { fg = c.green } }

hl.plugins.nvim_cmp = {
  CmpItemMenuDefault = colors.Fg,
  CmpItemKindDefault = colors.Orange,
  CmpItemAbbr = colors.Fg,
  CmpItemAbbrMatch = colors.Green,
  CmpItemAbbrMatchFuzzy = colors.Yellow,
  CmpDocumentation = { fg = c.fg },
  CmpDocumentationBorder = { fg = c.bg3 },
  CmpItemAbbrDeprecated = { fg = c.grey },
  CmpItemKind = { fg = c.orange },
  CmpItemMenu = { fg = c.grey },
}

hl.plugins.fidget = {
  FidgetTitle = { fg = c.green },
  FidgetTask = { fg = c.orange },
}

hl.langs.html = {
  htmlTag = colors.Red,
  htmlTagName = colors.Red,
}

hl.langs.markdown = {
  markdownBlockquote = colors.Grey,
  markdownBold = { fg = c.none, bold = true },
  markdownBoldDelimiter = colors.Grey,
  markdownCode = colors.Yellow,
  markdownCodeBlock = colors.Yellow,
  markdownCodeDelimiter = colors.Green,
  htmlH1 = { fg = c.red, bold = true },
  htmlH2 = { fg = c.red, bold = true },
  htmlH3 = { fg = c.red, bold = true },
  htmlH4 = { fg = c.red, bold = true },
  htmlH5 = { fg = c.red, bold = true },
  htmlH6 = { fg = c.red, bold = true },
  markdownHeadingDelimiter = colors.Grey,
  markdownHeadingRule = colors.Grey,
  markdownId = colors.Yellow,
  markdownIdDeclaration = colors.Red,
  markdownItalic = { fg = c.none, italic = true },
  markdownItalicDelimiter = { fg = c.grey, italic = true },
  markdownLinkDelimiter = colors.Grey,
  markdownLinkText = colors.Red,
  markdownLinkTextDelimiter = colors.Grey,
  markdownListMarker = colors.Red,
  markdownOrderedListMarker = colors.Red,
  markdownRule = colors.Purple,
  markdownUrl = { fg = c.blue, underline = true },
  markdownUrlDelimiter = colors.Grey,
  markdownUrlTitleDelimiter = colors.Green,
}

hl.langs.gitcommit = {
  gitcommitComment = { fg = c.grey },
  gitcommitUnmerged = { fg = c.green },
  gitcommitOnBranch = {},
  gitcommitBranch = { fg = c.yellow },
  gitcommitDiscardedType = { fg = c.red },
  gitcommitSelectedType = { fg = c.green },
  gitcommitHeader = {},
  gitcommitUntrackedFile = { fg = c.cyan },
  gitcommitDiscardedFile = { fg = c.red },
  gitcommitSelectedFile = { fg = c.green },
  gitcommitUnmergedFile = { fg = c.yellow },
  gitcommitFile = {},
  gitcommitSummary = { fg = c.fg },
  gitcommitOverflow = { fg = c.red },
  gitcommitNoBranch = { fg = c.yellow },
  gitcommitUntracked = { fg = c.cyan },
  gitcommitDiscarded = { fg = c.red },
  gitcommitSelected = { fg = c.green },
  gitcommitDiscardedArrow = { fg = c.red },
  gitcommitSelectedArrow = { fg = c.green },
  gitcommitUnmergedArrow = { fg = c.yellow },
}

hl.langs.yaml = {
  yamlBlockCollectionItemStart = colors.Fg,
  yamlKeyValueDelimiter = colors.Fg,
  yamlBlockMappingKey = colors.Red,
}

hl.langs.dockerCompose = { dockercomposeKeywords = colors.Red }

hl.langs.bash = { bashTSParameter = { fg = c.fg } }

hl.langs.jinja = {
  jinjaTagBlock = colors.Red,
  jinjaVarBlock = colors.Yellow,
  jinjaVariable = colors.Yellow,
  jinjaVarDelim = colors.BrightYellow,
  jinjaFilter = colors.Blue,
  jinjaStatement = colors.Red,
}

hl.langs.ansible = { ansible_normal_keywords = colors.Blue }

hl.plugins.notify = {
  NotifyERRORBorder = { fg = c.red },
  NotifyWARNBorder = { fg = c.orange },
  NotifyINFOBorder = { fg = c.green },
  NotifyDEBUGBorder = { fg = c.cyan },
  NotifyTRACEBorder = { fg = c.grey },
  NotifyERRORIcon = { fg = c.red },
  NotifyWARNIcon = { fg = c.orange },
  NotifyINFOIcon = { fg = c.green },
  NotifyDEBUGIcon = { fg = c.cyan },
  NotifyTRACEIcon = { fg = c.grey },
  NotifyERRORTitle = { fg = c.red },
  NotifyWARNTitle = { fg = c.orange },
  NotifyINFOTitle = { fg = c.green },
  NotifyDEBUGTitle = { fg = c.cyan },
  NotifyTRACETitle = { fg = c.grey },
  NotifyERRORBody = { fg = c.fg },
  NotifyWARNBody = { fg = c.fg },
  NotifyINFOBody = { fg = c.fg },
  NotifyDEBUGBody = { fg = c.fg },
  NotifyTRACEBody = { fg = c.fg },
}

hl.plugins.vim_visual_multi = {
  VM_Mono = { fg = c.none, bg = c.diff_text },
  VM_Insert = { fg = c.none, bg = c.diff_change },
  VM_Cursor = { bg = c.bg_blue },
  VM_Extend = { bg = c.dark_blue },
}

function M.setup()
  vim_highlights(hl.common)
  vim_highlights(hl.syntax)

  for _, group in pairs(hl.langs) do
    vim_highlights(group)
  end

  for _, group in pairs(hl.plugins) do
    vim_highlights(group)
  end

  local ns = create_namespace "onedarker"
  load_highlights(ns, hl.treesitter)
  set_hl_ns(ns)
  -- vim_highlights(hl.treesitter)
end

return M
