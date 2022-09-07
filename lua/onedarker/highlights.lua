local c = require "onedarker.colors"

local M = {}
local hl = { langs = {}, plugins = {} }

hl.common = {
  Underlined = { underline = true },
  Bold = { bold = true },
  Italic = { italic = true },

  Normal = { fg = c.fg, bg = c.bg[200] },
  Terminal = { fg = c.fg, bg = c.bg[200] },
  EndOfBuffer = { fg = c.bg[200], bg = c.bg[200] },
  SignColumn = { fg = c.fg, bg = c.bg[200] },
  MsgArea = { fg = c.fg, bg = c.bg[200] },
  FoldColumn = { fg = c.fg, bg = c.bg[200] },
  ModeMsg = { fg = c.fg, bg = c.bg[200] },
  MsgSeparator = { fg = c.fg, bg = c.bg[300] },
  VertSplit = { fg = c.bg[300] },

  Cursor = { reverse = true },
  vCursor = { bg = c.cursor },
  iCursor = { reverse = true },
  lCursor = { bg = c.cursor },
  CursorIM = { reverse = true },
  CursorColumn = { bg = c.bg[300] },
  CursorLine = { bg = c.bg[300] },
  ColorColumn = { bg = c.bg[300] },
  CursorLineNr = { fg = c.fg },
  Visual = { bg = c.bg[400] },
  VisualNOS = { fg = c.none, bg = c.bg[400] },
  TermCursorNC = { bg = c.cursor },
  LineNr = { fg = c.grey[600] },
  Conceal = { fg = c.grey[600], bg = c.bg[300] },
  Folded = { fg = c.fg, bg = c.bg[400] },
  NormalNC = { fg = c.fg, bg = c.bg[200] },

  DiffAdd = { fg = c.none, bg = c.diff.add },
  DiffChange = { fg = c.none, bg = c.diff.change },
  DiffDelete = { fg = c.none, bg = c.diff.delete },
  DiffText = { fg = c.none, bg = c.diff.text },
  DiffAdded = { fg = c.diff.add },
  DiffRemoved = { fg = c.diff.delete },
  DiffFile = { fg = c.diff.text },
  DiffIndexLine = { fg = c.diff.change },

  ErrorMsg = { fg = c.red[600], bold = true, bg = c.bg[200] },
  WarningMsg = { fg = c.orange[600], bold = true, bg = c.bg[200] },
  Question = { fg = c.yellow[600] },
  MoreMsg = { fg = c.cyan[600], bold = true, bg = c.bg[200] },

  Search = { bg = c.bg[500] },
  IncSearch = { bg = c.bg[600] },
  Substitute = { fg = c.bg[500], bg = c.orange[600] },
  MatchParen = { fg = c.blue[600], underline = true },
  MatchWord = { underline = true },
  MatchWordCur = { underline = true },
  MatchParenCur = { underline = true },

  Whitespace = { fg = c.red[600] },
  ExtraWhitespace = { bg = c.red[600] },

  SpellBad = { fg = c.red[600], sp = c.red[600] },
  SpellCap = { fg = c.yellow[600], sp = c.yellow[600] },
  SpellLocal = { fg = c.blue[600], sp = c.blue[600] },
  SpellRare = { fg = c.purple[600], sp = c.purple[600] },

  ToolbarLine = { fg = c.fg },

  TabLine = { fg = c.fg, bg = c.bg[300] },
  TabLineFill = { fg = c.grey[600], bg = c.bg[200] },
  TabLineSel = { fg = c.fg, bg = c.bg[200] },

  StatusLine = { fg = c.fg, bg = c.bg[300] },
  StatusLineTerm = { fg = c.bg[200], bg = c.bg[300] },
  StatusLineNC = { fg = c.grey[600], bg = c.bg[400] },
  StatusLineTermNC = { fg = c.bg[200], bg = c.bg[400] },

  NormalFloat = { bg = c.bg[300] },
  FloatBorder = { fg = c.orange[300] },

  Pmenu = { fg = c.fg, bg = c.bg[300] },
  PmenuSbar = { fg = c.none, bg = c.bg[300] },
  PmenuSel = { fg = c.bg[200], bg = c.blue[900] },
  PmenuThumb = { fg = c.none, bg = c.grey[600] },

  WildMenu = { fg = c.bg[200], bg = c.blue[600] },

  QuickFixLine = { fg = c.blue[600] },

  SpecialKey = { fg = c.grey[600] },
  ToolbarButton = { fg = c.bg[200], bg = c.blue[900] },

  Directory = { fg = c.blue[600] },
  NonText = { fg = c.grey[600] },
  Debug = { fg = c.yellow[600] },
  debugPC = { fg = c.bg[200], bg = c.cyan[600] },
  debugBreakpoint = { fg = c.bg[200], bg = c.red[600] },
  Ignore = { fg = c.cyan[600], bg = c.bg[200], bold = true },
}

hl.syntax = {
  String = { fg = c.green[600] },
  Character = { fg = c.orange[600] },
  Variable = { fg = c.red[600] },
  Float = { fg = c.orange[300] },
  confComment = { fg = c.grey[600] },
  Number = { fg = c.orange[600] },
  Boolean = { fg = c.orange[600] },
  Type = { fg = c.yellow[600] },
  Structure = { fg = c.yellow[600] },
  StorageClass = { fg = c.yellow[600] },
  Identifier = { fg = c.red[600] },
  Constant = { fg = c.yellow[600] },
  PreProc = { fg = c.purple[600] },
  PreCondit = { fg = c.purple[600] },
  Include = { fg = c.purple[600] },
  Keyword = { fg = c.purple[600] },
  Define = { fg = c.purple[600] },
  Typedef = { fg = c.purple[600] },
  Exception = { fg = c.purple[600] },
  Conditional = { fg = c.purple[600] },
  Repeat = { fg = c.purple[600] },
  Statement = { fg = c.purple[600] },
  Macro = { fg = c.red[600] },
  Error = { fg = c.purple[600] },
  Label = { fg = c.red[600] },
  Special = { fg = c.red[600] },
  SpecialChar = { fg = c.red[600] },
  Function = { fg = c.blue[600] },
  Operator = { fg = c.cyan[600] },
  Title = { fg = c.cyan[600] },
  Tag = { fg = c.green[300] },
  Delimiter = { fg = c.grey[900] },
  Comment = { italic = true, fg = c.grey[600] },
  SpecialComment = { italic = true, fg = c.grey[600] },
  Todo = { fg = c.red[600] },
}

hl.treesitter = {
  TSAnnotation = { fg = c.fg },
  TSAttribute = { fg = c.cyan[600] },
  TSBoolean = { fg = c.orange[600] },
  TSCharacter = { fg = c.fg },
  TSComment = { fg = c.grey[600], italic = true },
  TSConditional = { fg = c.purple[600] },
  TSConstant = { fg = c.yellow[600] },
  TSConstBuiltin = { fg = c.orange[600] },
  TSConstMacro = { fg = c.orange[600] },
  TSConstructor = { fg = c.yellow[600] },
  TSError = { fg = c.fg },
  TSException = { fg = c.purple[600] },
  TSField = { fg = c.red[600] },
  TSFloat = { fg = c.green[300] },
  TSFunction = { fg = c.blue[600] },
  TSFuncBuiltin = { fg = c.cyan[600] },
  TSFuncMacro = { fg = c.fg },
  TSInclude = { fg = c.purple[600] },
  TSKeyword = { fg = c.purple[600] },
  TSKeywordFunction = { fg = c.purple[600] },
  TSKeywordOperator = { fg = c.purple[600] },
  TSLabel = { fg = c.red[600] },
  TSMethod = { fg = c.blue[600] },
  TSNamespace = { fg = c.red[600] },
  TSNone = { fg = c.fg },
  TSNumber = { fg = c.orange[600] },
  TSOperator = { fg = c.cyan[600] },
  TSParameter = { fg = c.red[600] },
  TSParameterReference = { fg = c.fg },
  TSProperty = { fg = c.red[600] },
  typescriptDecorator = { fg = c.fg },
  TSPunctDelimiter = { fg = c.fg },
  TSPunctBracket = { fg = c.yellow[900] },
  TSPunctSpecial = { fg = c.purple[600] },
  TSRepeat = { fg = c.purple[600] },
  TSString = { fg = c.green[600] },
  TSStringRegex = { fg = c.orange[600] },
  TSStringEscape = { fg = c.red[600] },
  TSSymbol = { fg = c.cyan[600] },
  TSTag = { fg = c.red[600] },
  TSTagDelimiter = { fg = c.grey[900] },
  TSText = { fg = c.fg },
  TSStrong = { fg = c.fg },
  TSEmphasis = { fg = c.fg },
  TSUnderline = { fg = c.fg },
  TSStrike = { fg = c.fg },
  TSTitle = { fg = c.fg },
  TSLiteral = { fg = c.green[300] },
  TSURI = { fg = c.fg },
  TSMath = { fg = c.fg },
  TSTextReference = { fg = c.fg },
  TSEnviroment = { fg = c.fg },
  TSEnviromentName = { fg = c.fg },
  TSNote = { fg = c.fg },
  TSWarning = { fg = c.fg },
  TSDanger = { fg = c.fg },
  TSType = { fg = c.yellow[600] },
  TSTypeBuiltin = { fg = c.yellow[600] },
  TSVariable = { fg = c.red[600] },
  TSVariableBuiltin = { fg = c.yellow[600] },
  TSKeywordReturn = { fg = c.purple[600] },
  TSTagAttribute = { fg = c.orange[600] },
  TSQueryLinterError = { fg = c.orange[600] },
  TSEnvironment = { fg = c.fg },
  TSEnvironmentName = { fg = c.fg },
  TSInlayHint = { italic = true, bg = c.bg[300], fg = c.bg[600] },
}

hl.lsp = {
  DiagnosticVirtualTextError = { fg = c.red[600] },
  DiagnosticVirtualTextWarning = { fg = c.orange[600] },
  DiagnosticVirtualTextInformation = { fg = c.cyan[600] },
  DiagnosticVirtualTextInfo = { fg = c.cyan[600] },
  DiagnosticVirtualTextHint = { fg = c.grey[600] },
  DiagnosticSignError = { fg = c.red[600] },
  DiagnosticSignWarn = { fg = c.orange[600] },
  DiagnosticSignInfo = { fg = c.cyan[600] },
  DiagnosticSignHint = { fg = c.grey[600] },
  DiagnosticFloatingError = { fg = c.red[600] },
  DiagnosticFloatingWarn = { fg = c.orange[600] },
  DiagnosticFloatingInfo = { fg = c.cyan[600] },
  DiagnosticFloatingHint = { fg = c.grey[600] },
  DiagnosticError = { fg = c.red[600] },
  DiagnosticWarning = { fg = c.orange[600] },
  DiagnosticInformation = { fg = c.cyan[600] },
  DiagnosticHint = { fg = c.grey[600] },
  LspDiagnosticsDefaultError = { fg = c.red[600] },
  LspDiagnosticsDefaultHint = { fg = c.grey[600] },
  LspDiagnosticsDefaultInformation = { fg = c.cyan[600] },
  LspDiagnosticsDefaultWarning = { fg = c.orange[600] },
  LspDiagnosticsUnderlineError = { underline = true },
  LspDiagnosticsUnderlineHint = { underline = true },
  LspDiagnosticsUnderlineInformation = { underline = true },
  LspDiagnosticsUnderlineWarning = { underline = true },
  DiagnosticUnderlineError = { underline = true },
  DiagnosticUnderlineWarn = { underline = true },
  DiagnosticUnderlineInfo = { underline = true },
  DiagnosticUnderlineHint = { underline = true },
  LspDiagnosticsVirtualTextError = { fg = c.red[600] },
  LspDiagnosticsVirtualTextWarning = { fg = c.orange[600] },
  LspDiagnosticsVirtualTextInformation = { fg = c.cyan[600] },
  LspDiagnosticsVirtualTextHint = { fg = c.grey[600] },
  LspReferenceText = { bg = c.bg[300], bold = false },
  LspReferenceWrite = { bg = c.bg[300], bold = false },
  LspReferenceRead = { bg = c.bg[300], bold = false },
  LspDiagnosticsFloatingError = { fg = c.red[600] },
  LspDiagnosticsFloatingWarning = { fg = c.orange[600] },
  LspDiagnosticsFloatingInformation = { fg = c.cyan[600] },
  LspDiagnosticsFloatingHint = { fg = c.grey[600] },
  LspDiagnosticsSignError = { fg = c.red[600] },
  LspDiagnosticsSignWarning = { fg = c.orange[600] },
  LspDiagnosticsSignInformation = { fg = c.cyan[600] },
  LspDiagnosticsSignHint = { fg = c.grey[600] },
  LspDiagnosticsError = { fg = c.red[600] },
  LspDiagnosticsWarning = { fg = c.orange[600] },
  LspDiagnosticsInformation = { fg = c.cyan[600] },
  LspDiagnosticsHint = { fg = c.grey[600] },
}

-- langs

hl.langs.html = {
  htmlTag = { fg = c.red[600] },
  htmlTagName = { fg = c.red[600] },
}

hl.langs.markdown = {
  markdownBlockquote = { fg = c.grey[600] },
  markdownBold = { fg = c.none, bold = true },
  markdownBoldDelimiter = { fg = c.grey[600] },
  markdownCode = { fg = c.yellow[600] },
  markdownCodeBlock = { fg = c.yellow[600] },
  markdownCodeDelimiter = { fg = c.green[300] },
  htmlH1 = { fg = c.red[600], bold = true },
  htmlH2 = { fg = c.red[600], bold = true },
  htmlH3 = { fg = c.red[600], bold = true },
  htmlH4 = { fg = c.red[600], bold = true },
  htmlH5 = { fg = c.red[600], bold = true },
  htmlH6 = { fg = c.red[600], bold = true },
  markdownHeadingDelimiter = { fg = c.grey[600] },
  markdownHeadingRule = { fg = c.grey[600] },
  markdownId = { fg = c.yellow[600] },
  markdownIdDeclaration = { fg = c.red[600] },
  markdownItalic = { fg = c.none, italic = true },
  markdownItalicDelimiter = { fg = c.grey[600], italic = true },
  markdownLinkDelimiter = { fg = c.grey[600] },
  markdownLinkText = { fg = c.red[600] },
  markdownLinkTextDelimiter = { fg = c.grey[600] },
  markdownListMarker = { fg = c.red[600] },
  markdownOrderedListMarker = { fg = c.red[600] },
  markdownRule = { fg = c.purple[600] },
  markdownUrl = { fg = c.blue[600], underline = true },
  markdownUrlDelimiter = { fg = c.grey[600] },
  markdownUrlTitleDelimiter = { fg = c.green[300] },
}

hl.langs.gitcommit = {
  gitcommitComment = { fg = c.grey[600] },
  gitcommitUnmerged = { fg = c.green[300] },
  gitcommitOnBranch = {},
  gitcommitBranch = { fg = c.yellow[600] },
  gitcommitDiscardedType = { fg = c.red[600] },
  gitcommitSelectedType = { fg = c.green[300] },
  gitcommitHeader = {},
  gitcommitUntrackedFile = { fg = c.cyan[600] },
  gitcommitDiscardedFile = { fg = c.red[600] },
  gitcommitSelectedFile = { fg = c.green[300] },
  gitcommitUnmergedFile = { fg = c.yellow[600] },
  gitcommitFile = {},
  gitcommitSummary = { fg = c.fg },
  gitcommitOverflow = { fg = c.red[600] },
  gitcommitNoBranch = { fg = c.yellow[600] },
  gitcommitUntracked = { fg = c.cyan[600] },
  gitcommitDiscarded = { fg = c.red[600] },
  gitcommitSelected = { fg = c.green[300] },
  gitcommitDiscardedArrow = { fg = c.red[600] },
  gitcommitSelectedArrow = { fg = c.green[300] },
  gitcommitUnmergedArrow = { fg = c.yellow[600] },
}

hl.langs.yaml = {
  yamlBlockCollectionItemStart = { fg = c.fg },
  yamlKeyValueDelimiter = { fg = c.fg },
  yamlBlockMappingKey = { fg = c.red[600] },
}

hl.langs.docker_compose = { dockercomposeKeywords = { fg = c.red[600] } }

hl.langs.bash = { bashTSParameter = { fg = c.fg } }

hl.langs.jinja = {
  jinjaTagBlock = { fg = c.yellow[600] },
  jinjaStatement = { fg = c.purple[600] },
  jinjaVarBlock = { fg = c.red[600] },
  jinjaVariable = { fg = c.red[600] },
  jinjaOperator = { fg = c.yellow[600] },
  jinjaVarDelim = { fg = c.yellow[900] },
  jinjaFilter = { fg = c.blue[600] },
}

hl.langs.ansible = { ansible_normal_keywords = { fg = c.blue[600] } }

-- plugins

hl.plugins.whichkey = {
  WhichKey = { fg = c.red[600] },
  WhichKeyDesc = { fg = c.blue[600] },
  WhichKeyGroup = { fg = c.orange[600] },
  WhichKeySeperator = { fg = c.green[300] },
  WhichKeyFloat = { bg = c.bg[300] },
}

hl.plugins.gitgutter = {
  GitGutterAdd = { fg = c.green[300] },
  GitGutterChange = { fg = c.cyan[900] },
  GitGutterDelete = { fg = c.red[900] },
}

hl.plugins.hop = {
  HopNextKey = { fg = c.bg[200], bg = c.orange[600] },
  HopNextKey1 = { fg = c.bg[200], bg = c.orange[600] },
  HopNextKey2 = { fg = c.bg[200], bg = c.yellow[300] },
  HopUnmatched = {},
}

hl.plugins.vim_illuminate = {
  IlluminatedWordText = { bg = c.bg[300] },
  IlluminatedWordWrite = { bg = c.bg[300] },
  IlluminatedWordRead = { bg = c.bg[300] },
}

hl.plugins.indentblankline = {
  IndentBlankLineChar = { fg = c.bg[500] },
  IndentBlanklineContextChar = { fg = c.cursor },
}

hl.plugins.diffview = {
  DiffviewFilePanelTitle = { fg = c.blue[600], bold = true },
  DiffviewFilePanelCounter = { fg = c.purple[600], bold = true },
  DiffviewFilePanelFileName = { fg = c.fg },
  DiffviewNormal = hl.common.Normal,
  DiffviewCursorLine = hl.common.CursorLine,
  DiffviewVertSplit = hl.common.VertSplit,
  DiffviewSignColumn = hl.common.SignColumn,
  DiffviewStatusLine = hl.common.StatusLine,
  DiffviewStatusLineNC = hl.common.StatusLineNC,
  DiffviewEndOfBuffer = hl.common.EndOfBuffer,
  DiffviewFilePanelRootPath = { fg = c.grey[600] },
  DiffviewFilePanelPath = { fg = c.grey[600] },
  DiffviewFilePanelInsertions = { fg = c.green[300] },
  DiffviewFilePanelDeletions = { fg = c.red[600] },
  DiffviewStatusAdded = { fg = c.green[300] },
  DiffviewStatusUntracked = { fg = c.grey[600] },
  DiffviewStatusModified = { fg = c.blue[600] },
  DiffviewStatusRenamed = { fg = c.yellow[600] },
  DiffviewStatusCopied = { fg = c.yellow[900] },
  DiffviewStatusTypeChange = { fg = c.cyan[600] },
  DiffviewStatusUnmerged = { fg = c.orange[600] },
  DiffviewStatusUnknown = { fg = c.red[600] },
  DiffviewStatusDeleted = { fg = c.red[600] },
  DiffviewStatusBroken = { fg = c.red[600] },
}

hl.plugins.gitsigns = {
  GitSignsAdd = { fg = c.green[300] },
  GitSignsAddLn = { fg = c.green[300] },
  GitSignsAddNr = { fg = c.green[300] },
  GitSignsChange = { fg = c.blue[600] },
  GitSignsChangeLn = { fg = c.blue[600] },
  GitSignsChangeNr = { fg = c.blue[600] },
  GitSignsDelete = { fg = c.red[600] },
  GitSignsDeleteLn = { fg = c.red[600] },
  GitSignsDeleteNr = { fg = c.red[600] },
}

hl.plugins.nvim_tree = {
  NvimTreeNormal = { fg = c.fg, bg = c.bg[200] },
  NvimTreeEndOfBuffer = { fg = c.bg[200], bg = c.bg[200] },
  NvimTreeRootFolder = { fg = c.purple[600], bold = true },
  NvimTreeGitDirty = { fg = c.orange[600] },
  NvimTreeGitNew = { fg = c.green[300] },
  NvimTreeGitDeleted = { fg = c.red[600] },
  NvimTreeSpecialFile = { fg = c.yellow[600] },
  NvimTreeIndentMarker = { fg = c.fg },
  NvimTreeImageFile = { fg = c.purple[600] },
  NvimTreeSymlink = { fg = c.purple[600] },
  NvimTreeFolderName = { fg = c.blue[600] },
}

-- hl.plugins.neotree_nvim = {
--   NeoTreeIndentMarker = { fg = c.bg[400] },
--   NeoTreeExpander = { fg = c.bg[500] },
--   NeoTreeBufferNumber = {},
--   NeoTreeCursorLine = {},
--   NeoTreeDimText = { fg = c.bg[500] },
--   NeoTreeDirectoryIcon = {},
--   NeoTreeDirectoryName = {},
--   NeoTreeDotfile = { fg = c.bg[700] },
--   NeoTreeFadeText1 = {},
--   NeoTreeFadeText2 = {},
--   NeoTreeFileIcon = {},
--   NeoTreeFileName = {},
--   NeoTreeFileNameOpened = {},
--   NeoTreeFilterTerm = {},
--   NeoTreeFloatBorder = {},
--   NeoTreeFloatTitle = {},
--   NeoTreeModified = { fg = c.blue[900] },
--   NeoTreeGitAdded = { fg = c.green[300] },
--   NeoTreeGitConflict = { fg = c.orange[600] },
--   NeoTreeGitDeleted = { fg = c.red[900] },
--   NeoTreeGitIgnored = { fg = c.grey[600] },
--   NeoTreeGitModified = { fg = c.yellow[900] },
--   NeoTreeGitRenamed = { fg = c.magenta[900] },
--   NeoTreeGitUntracked = { fg = c.green[300] },
--   NeoTreeHiddenByName = {},
--   NeoTreeNormal = {},
--   NeoTreeNormalNC = {},
--   NeoTreeRootName = {},
--   NeoTreeSymbolicLinkTarget = { c.cyan[600] },
--   NeoTreeTitleBar = {},
-- }

hl.plugins.telescope = {
  TelescopeBorder = { fg = c.grey[600] },
  TelescopeMatching = { fg = c.green[300] },
  TelescopeNormal = { bg = c.bg[200], fg = c.fg },
  TelescopePromptPrefix = { fg = c.yellow[600] },
  TelescopeSelection = { bg = c.bg[400] },
  TelescopeSelectionCaret = { fg = c.yellow[600] },
}

hl.plugins.dashboard = {
  DashboardShortcut = { fg = c.fg },
  DashboardHeader = { fg = c.orange[600] },
  DashboardCenter = { fg = c.yellow[600] },
  DashboardFooter = { fg = c.grey[600], bold = true },
}

hl.plugins.spectre = {
  SpectreChange = { fg = c.yellow[600] },
  SpectreDelete = { fg = c.green[300] },
}

hl.plugins.nvim_cmp = {
  CmpItemMenuDefault = { fg = c.fg },
  CmpItemKindDefault = { fg = c.orange[300] },
  CmpItemAbbr = { fg = c.fg },
  CmpItemAbbrMatch = { fg = c.green[300] },
  CmpItemAbbrMatchFuzzy = { fg = c.yellow[300] },
  CmpDocumentation = { fg = c.fg },
  CmpDocumentationBorder = { fg = c.bg[500] },
  CmpItemAbbrDeprecated = { fg = c.grey[600] },
  CmpItemKind = { fg = c.orange[300] },
  CmpItemMenu = { fg = c.grey[600] },
}

hl.plugins.fidget = {
  FidgetTitle = { fg = c.green[300] },
  FidgetTask = { fg = c.orange[300] },
}

hl.plugins.notify = {
  NotifyERRORBorder = { fg = c.red[600] },
  NotifyWARNBorder = { fg = c.orange[600] },
  NotifyINFOBorder = { fg = c.green[300] },
  NotifyDEBUGBorder = { fg = c.cyan[600] },
  NotifyTRACEBorder = { fg = c.grey[600] },
  NotifyERRORIcon = { fg = c.red[600] },
  NotifyWARNIcon = { fg = c.orange[600] },
  NotifyINFOIcon = { fg = c.green[300] },
  NotifyDEBUGIcon = { fg = c.cyan[600] },
  NotifyTRACEIcon = { fg = c.grey[600] },
  NotifyERRORTitle = { fg = c.red[600] },
  NotifyWARNTitle = { fg = c.orange[600] },
  NotifyINFOTitle = { fg = c.green[300] },
  NotifyDEBUGTitle = { fg = c.cyan[600] },
  NotifyTRACETitle = { fg = c.grey[600] },
  NotifyERRORBody = { fg = c.fg },
  NotifyWARNBody = { fg = c.fg },
  NotifyINFOBody = { fg = c.fg },
  NotifyDEBUGBody = { fg = c.fg },
  NotifyTRACEBody = { fg = c.fg },
}

hl.plugins.vim_visual_multi = {
  VM_Mono = { fg = c.none, bg = c.blue[600] },
  VM_Insert = { fg = c.none, bg = c.blue[300] },
  VM_Cursor = { bg = c.blue[900] },
  VM_Extend = { bg = c.blue[300] },
}

hl.plugins.symbols_outline = {
  FocusedSymbol = { bg = c.bg[300] },
}

hl.plugins.aerojump = {
  SearchResult = { bg = c.yellow[600] },
  SearchHighlight = { bg = c.green[300] },
}

-- setup
-- local function find_duplicates(t)
--   local Log = require "lvim.core.log"
--
--   local seen = {} --keep record of elements we've seen
--   local duplicated = {} --keep a record of duplicated elements
--   for i = 1, #t do
--     local element = t[i]
--     if seen[element] then --check if we've seen the element before
--       duplicated[element] = true --if we have then it must be a duplicate! add to a table to keep track of this
--     else
--       seen[element] = true -- set the element to seen
--     end
--   end
--   Log:warn(string.format("Duplicated highlights: %s", vim.inspect(duplicated)))
-- end

function M.load_highlights(ns, highlights, loaded)
  for group_name, group_settings in pairs(highlights) do
    -- table.insert(loaded, group_name)
    vim.api.nvim_set_hl(ns, group_name, group_settings)
  end
end

function M.setup()
  local loaded = {}
  local ns = vim.api.nvim_create_namespace "onedarker"

  M.load_highlights(0, hl.common, loaded)
  M.load_highlights(0, hl.syntax, loaded)
  M.load_highlights(0, hl.lsp, loaded)

  for _, group in pairs(hl.langs) do
    M.load_highlights(0, group, loaded)
  end

  for _, group in pairs(hl.plugins) do
    M.load_highlights(0, group, loaded)
  end

  M.load_highlights(0, hl.treesitter, loaded)
  -- M.load_highlights(ns, hl.treesitter)
  vim.api.nvim_set_hl_ns(ns)

  -- find_duplicates(loaded)
end

return M
