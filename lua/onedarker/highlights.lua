local c = require "onedarker.colors"

local M = {}
local hl = { langs = {}, plugins = {} }

hl.common = {
  Normal = { fg = c.fg, bg = c.bg0 },
  Terminal = { fg = c.fg, bg = c.bg0 },
  EndOfBuffer = { fg = c.bg0, bg = c.bg0 },
  FoldColumn = { fg = c.fg, bg = c.bg2 },
  Folded = { fg = c.fg, bg = c.bg2 },
  SignColumn = { fg = c.fg, bg = c.bg0 },
  ToolbarLine = { fg = c.fg },
  Cursor = { reverse = true },
  vCursor = { bg = c.cursor },
  iCursor = { reverse = true },
  lCursor = { bg = c.cursor },
  CursorIM = { reverse = true },
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
  DiffAdded = { fg = c.green },
  DiffRemoved = { fg = c.red },
  DiffFile = { fg = c.cyan },
  DiffIndexLine = { fg = c.grey },
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
  FloatBorder = { fg = c.grey, bg = c.bg1 },
  NormalFloat = { bg = c.bg1 },
  MatchWord = { underline = true },
  MatchWordCur = { underline = true },
  MatchParenCur = { underline = true },
  TermCursorNC = { bg = c.cursor },
  Title = { fg = c.blue, bold = true },
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
  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },
  Ignore = { fg = c.cyan, bg = c.bg, bold = true },
  Todo = { fg = c.red, bg = c.bg, bold = true },
  Error = { fg = c.dark_red, bg = c.bg, bold = true },
}

hl.syntax = {
  String = { fg = c.green },
  Character = { fg = c.orange },
  confComment = { fg = c.grey },
  NormalFloat = { bg = c.bg1 },
  FloatBorder = { fg = c.orange },
  Number = { fg = c.orange },
  Float = { fg = c.orange },
  Boolean = { fg = c.orange },
  Type = { fg = c.yellow },
  Structure = { fg = c.yellow },
  StorageClass = { fg = c.yellow },
  Identifier = { fg = c.red },
  Constant = { fg = c.yellow },
  PreProc = { fg = c.purple },
  PreCondit = { fg = c.purple },
  Include = { fg = c.purple },
  Keyword = { fg = c.purple },
  Define = { fg = c.purple },
  Typedef = { fg = c.purple },
  Exception = { fg = c.purple },
  Conditional = { fg = c.purple },
  Repeat = { fg = c.purple },
  Statement = { fg = c.purple },
  Macro = { fg = c.red },
  Error = { fg = c.purple },
  Label = { fg = c.red },
  Special = { fg = c.red },
  SpecialChar = { fg = c.red },
  Function = { fg = c.blue },
  Operator = { fg = c.cyan },
  Title = { fg = c.cyan },
  Tag = { fg = c.green },
  Delimiter = { fg = c.bright_grey },
  Comment = { italic = true, fg = c.grey },
  SpecialComment = { italic = true, fg = c.grey },
  Todo = { fg = c.red },
}

hl.treesitter = {
  TSAnnotation = { fg = c.fg },
  TSAttribute = { fg = c.cyan },
  TSBoolean = { fg = c.orange },
  TSCharacter = { fg = c.fg },
  TSComment = { fg = c.grey, italic = true },
  TSConditional = { fg = c.purple },
  TSConstant = { fg = c.yellow },
  TSConstBuiltin = { fg = c.orange },
  TSConstMacro = { fg = c.orange },
  TSConstructor = { fg = c.yellow },
  TSError = { fg = c.fg },
  TSException = { fg = c.purple },
  TSField = { fg = c.red },
  TSFloat = { fg = c.green },
  TSFunction = { fg = c.blue },
  TSFuncBuiltin = { fg = c.cyan },
  TSFuncMacro = { fg = c.fg },
  TSInclude = { fg = c.purple },
  TSKeyword = { fg = c.purple },
  TSKeywordFunction = { fg = c.purple },
  TSKeywordOperator = { fg = c.purple },
  TSLabel = { fg = c.red },
  TSMethod = { fg = c.blue },
  TSNamespace = { fg = c.red },
  TSNone = { fg = c.fg },
  TSNumber = { fg = c.orange },
  TSOperator = { fg = c.cyan },
  TSParameter = { fg = c.red },
  TSParameterReference = { fg = c.fg },
  TSProperty = { fg = c.red },
  typescriptDecorator = { fg = c.fg },
  TSPunctDelimiter = { fg = c.fg },
  TSPunctBracket = { fg = c.bright_yellow },
  TSPunctSpecial = { fg = c.purple },
  TSRepeat = { fg = c.purple },
  TSString = { fg = c.green },
  TSStringRegex = { fg = c.orange },
  TSStringEscape = { fg = c.red },
  TSSymbol = { fg = c.cyan },
  TSTag = { fg = c.red },
  TSTagDelimiter = { fg = c.bright_grey },
  TSText = { fg = c.fg },
  TSStrong = { fg = c.fg },
  TSEmphasis = { fg = c.fg },
  TSUnderline = { fg = c.fg },
  TSStrike = { fg = c.fg },
  TSTitle = { fg = c.fg },
  TSLiteral = { fg = c.green },
  TSURI = { fg = c.fg },
  TSMath = { fg = c.fg },
  TSTextReference = { fg = c.fg },
  TSEnviroment = { fg = c.fg },
  TSEnviromentName = { fg = c.fg },
  TSNote = { fg = c.fg },
  TSWarning = { fg = c.fg },
  TSDanger = { fg = c.fg },
  TSType = { fg = c.yellow },
  TSTypeBuiltin = { fg = c.yellow },
  TSVariable = { fg = c.red },
  TSVariableBuiltin = { fg = c.yellow },
  TSKeywordReturn = { fg = c.purple },
  TSTagAttribute = { fg = c.orange },
  TSQueryLinterError = { fg = c.orange },
  TSEnvironment = { fg = c.fg },
  TSEnvironmentName = { fg = c.fg },
  TSInlayHint = { italic = true, bg = c.bg1, fg = c.bg_d },
}

hl.lsp = {
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
  LspDiagnosticsUnderlineError = { underline = true },
  LspDiagnosticsUnderlineHint = { underline = true },
  LspDiagnosticsUnderlineInformation = { underline = true },
  LspDiagnosticsUnderlineWarning = { underline = true },
  DiagnosticUnderlineError = { underline = true },
  DiagnosticUnderlineWarn = { underline = true },
  DiagnosticUnderlineInfo = { underline = true },
  DiagnosticUnderlineHint = { underline = true },
  LspDiagnosticsVirtualTextError = { fg = c.red },
  LspDiagnosticsVirtualTextWarning = { fg = c.orange },
  LspDiagnosticsVirtualTextInformation = { fg = c.dark_cyan },
  LspDiagnosticsVirtualTextHint = { fg = c.grey },
  LspReferenceText = { bg = c.bg1, bold = false },
  LspReferenceWrite = { bg = c.bg1, bold = false },
  LspReferenceRead = { bg = c.bg1, bold = false },
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

-- langs

hl.langs.html = {
  htmlTag = { fg = c.red },
  htmlTagName = { fg = c.red },
}

hl.langs.markdown = {
  markdownBlockquote = { fg = c.grey },
  markdownBold = { fg = c.none, bold = true },
  markdownBoldDelimiter = { fg = c.grey },
  markdownCode = { fg = c.yellow },
  markdownCodeBlock = { fg = c.yellow },
  markdownCodeDelimiter = { fg = c.green },
  htmlH1 = { fg = c.red, bold = true },
  htmlH2 = { fg = c.red, bold = true },
  htmlH3 = { fg = c.red, bold = true },
  htmlH4 = { fg = c.red, bold = true },
  htmlH5 = { fg = c.red, bold = true },
  htmlH6 = { fg = c.red, bold = true },
  markdownHeadingDelimiter = { fg = c.grey },
  markdownHeadingRule = { fg = c.grey },
  markdownId = { fg = c.yellow },
  markdownIdDeclaration = { fg = c.red },
  markdownItalic = { fg = c.none, italic = true },
  markdownItalicDelimiter = { fg = c.grey, italic = true },
  markdownLinkDelimiter = { fg = c.grey },
  markdownLinkText = { fg = c.red },
  markdownLinkTextDelimiter = { fg = c.grey },
  markdownListMarker = { fg = c.red },
  markdownOrderedListMarker = { fg = c.red },
  markdownRule = { fg = c.purple },
  markdownUrl = { fg = c.blue, underline = true },
  markdownUrlDelimiter = { fg = c.grey },
  markdownUrlTitleDelimiter = { fg = c.green },
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
  yamlBlockCollectionItemStart = { fg = c.fg },
  yamlKeyValueDelimiter = { fg = c.fg },
  yamlBlockMappingKey = { fg = c.red },
}

hl.langs.docker_compose = { dockercomposeKeywords = { fg = c.red } }

hl.langs.bash = { bashTSParameter = { fg = c.fg } }

hl.langs.jinja = {
  jinjaTagBlock = { fg = c.yellow },
  jinjaStatement = { fg = c.purple },
  jinjaVarBlock = { fg = c.red },
  jinjaVariable = { fg = c.red },
  jinjaOperator = { fg = c.yellow },
  jinjaVarDelim = { fg = c.bright_yellow },
  jinjaFilter = { fg = c.blue },
}

hl.langs.ansible = { ansible_normal_keywords = { fg = c.blue } }

-- plugins

hl.plugins.whichkey = {
  WhichKey = { fg = c.red },
  WhichKeyDesc = { fg = c.blue },
  WhichKeyGroup = { fg = c.orange },
  WhichKeySeperator = { fg = c.green },
  WhichKeyFloat = { bg = c.bg1 },
}

hl.plugins.git = {
  SignAdd = { fg = c.green },
  SignChange = { fg = c.blue },
  SignDelete = { fg = c.red },
  GitSignsAdd = { fg = c.green },
  GitSignsChange = { fg = c.blue },
  GitSignsDelete = { fg = c.red },
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

hl.plugins.vim_illuminate = {
  IlluminatedWordText = { bg = c.bg1 },
  IlluminatedWordWrite = { bg = c.bg1 },
  IlluminatedWordRead = { bg = c.bg1 },
}

hl.plugins.indentblankline = {
  IndentBlankLineChar = { fg = c.bg3 },
  IndentBlanklineContextChar = { fg = c.cursor },
}

hl.plugins.diffview = {
  DiffviewFilePanelTitle = { fg = c.blue, bold = true },
  DiffviewFilePanelCounter = { fg = c.purple, bold = true },
  DiffviewFilePanelFileName = { fg = c.fg },
  DiffviewNormal = hl.common.Normal,
  DiffviewCursorLine = hl.common.CursorLine,
  DiffviewVertSplit = hl.common.VertSplit,
  DiffviewSignColumn = hl.common.SignColumn,
  DiffviewStatusLine = hl.common.StatusLine,
  DiffviewStatusLineNC = hl.common.StatusLineNC,
  DiffviewEndOfBuffer = hl.common.EndOfBuffer,
  DiffviewFilePanelRootPath = { fg = c.grey },
  DiffviewFilePanelPath = { fg = c.grey },
  DiffviewFilePanelInsertions = { fg = c.green },
  DiffviewFilePanelDeletions = { fg = c.red },
  DiffviewStatusAdded = { fg = c.green },
  DiffviewStatusUntracked = { fg = c.grey },
  DiffviewStatusModified = { fg = c.blue },
  DiffviewStatusRenamed = { fg = c.yellow },
  DiffviewStatusCopied = { fg = c.bright_yellow },
  DiffviewStatusTypeChange = { fg = c.cyan },
  DiffviewStatusUnmerged = { fg = c.orange },
  DiffviewStatusUnknown = { fg = c.red },
  DiffviewStatusDeleted = { fg = c.red },
  DiffviewStatusBroken = { fg = c.red },
}

hl.plugins.gitsigns = {
  GitSignsAdd = { fg = c.green },
  GitSignsAddLn = { fg = c.green },
  GitSignsAddNr = { fg = c.green },
  GitSignsChange = { fg = c.blue },
  GitSignsChangeLn = { fg = c.blue },
  GitSignsChangeNr = { fg = c.blue },
  GitSignsDelete = { fg = c.red },
  GitSignsDeleteLn = { fg = c.red },
  GitSignsDeleteNr = { fg = c.red },
}

hl.plugins.nvim_tree = {
  NvimTreeNormal = { fg = c.fg, bg = c.bg0 },
  NvimTreeEndOfBuffer = { fg = c.bg0, bg = c.bg0 },
  NvimTreeRootFolder = { fg = c.purple, bold = true },
  NvimTreeGitDirty = { fg = c.orange },
  NvimTreeGitNew = { fg = c.green },
  NvimTreeGitDeleted = { fg = c.red },
  NvimTreeSpecialFile = { fg = c.yellow },
  NvimTreeIndentMarker = { fg = c.fg },
  NvimTreeImageFile = { fg = c.dark_purple },
  NvimTreeSymlink = { fg = c.purple },
  NvimTreeFolderName = { fg = c.blue },
}

-- hl.plugins.neotree_nvim = {
--   NeoTreeIndentMarker = { fg = c.bg2 },
--   NeoTreeExpander = { fg = c.bg3 },
--   NeoTreeBufferNumber = {},
--   NeoTreeCursorLine = {},
--   NeoTreeDimText = { fg = c.bg3 },
--   NeoTreeDirectoryIcon = {},
--   NeoTreeDirectoryName = {},
--   NeoTreeDotfile = { fg = c.bg4 },
--   NeoTreeFadeText1 = {},
--   NeoTreeFadeText2 = {},
--   NeoTreeFileIcon = {},
--   NeoTreeFileName = {},
--   NeoTreeFileNameOpened = {},
--   NeoTreeFilterTerm = {},
--   NeoTreeFloatBorder = {},
--   NeoTreeFloatTitle = {},
--   NeoTreeModified = { fg = c.bright_blue },
--   NeoTreeGitAdded = { fg = c.bright_green },
--   NeoTreeGitConflict = { fg = c.orange },
--   NeoTreeGitDeleted = { fg = c.bright_red },
--   NeoTreeGitIgnored = { fg = c.grey },
--   NeoTreeGitModified = { fg = c.bright_yellow },
--   NeoTreeGitRenamed = { fg = c.bright_magenta },
--   NeoTreeGitUntracked = { fg = c.bright_green },
--   NeoTreeHiddenByName = {},
--   NeoTreeNormal = {},
--   NeoTreeNormalNC = {},
--   NeoTreeRootName = {},
--   NeoTreeSymbolicLinkTarget = { c.cyan },
--   NeoTreeTitleBar = {},
-- }

hl.plugins.telescope = {
  TelescopeBorder = { fg = c.grey },
  TelescopeMatching = { fg = c.green },
  TelescopeNormal = { bg = c.bg, fg = c.fg },
  TelescopePromptPrefix = { fg = c.yellow },
  TelescopeSelection = { bg = c.bg2 },
  TelescopeSelectionCaret = { fg = c.yellow },
}

hl.plugins.dashboard = {
  DashboardShortcut = { fg = c.fg },
  DashboardHeader = { fg = c.orange },
  DashboardCenter = { fg = c.yellow },
  DashboardFooter = { fg = c.grey, bold = true },
}

hl.plugins.spectre = {
  SpectreChange = { fg = c.yellow },
  SpectreDelete = { fg = c.green },
}

hl.plugins.nvim_cmp = {
  CmpItemMenuDefault = { fg = c.fg },
  CmpItemKindDefault = { fg = c.orange },
  CmpItemAbbr = { fg = c.fg },
  CmpItemAbbrMatch = { fg = c.green },
  CmpItemAbbrMatchFuzzy = { fg = c.yellow },
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

hl.plugins.symbols_outline = {
  FocusedSymbol = { bg = c.bg1 },
}

hl.plugins.aerojump = {
  SearchResult = { bg = c.yellow },
  SearchHighlight = { bg = c.green },
}

-- setup
function M.load_highlights(ns, highlights)
  for group_name, group_settings in pairs(highlights) do
    vim.api.nvim_set_hl(ns, group_name, group_settings)
  end
end

function M.setup()
  local ns = vim.api.nvim_create_namespace "onedarker"

  M.load_highlights(0, hl.common)
  M.load_highlights(0, hl.syntax)
  M.load_highlights(0, hl.lsp)

  for _, group in pairs(hl.langs) do
    M.load_highlights(0, group)
  end

  for _, group in pairs(hl.plugins) do
    M.load_highlights(0, group)
  end

  M.load_highlights(0, hl.treesitter)
  -- M.load_highlights(ns, hl.treesitter)
  vim.api.nvim_set_hl_ns(ns)
end

return M
