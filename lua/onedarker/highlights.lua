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
  Folded = { fg = c.fg, bg = c.bg[300] },
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

  Search = { bg = c.bg[400] },
  IncSearch = { bg = c.bg[500] },
  WildMenu = { fg = c.fg, bg = c.blue[300] },
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

  NormalFloat = { bg = c.bg[200] },
  FloatBorder = { fg = c.orange[300], bg = c.bg[200] },

  Pmenu = { fg = c.fg, bg = c.bg[300] },
  PmenuSbar = { fg = c.none, bg = c.bg[300] },
  PmenuSel = { fg = c.bg[200], bg = c.blue[900] },
  PmenuThumb = { fg = c.none, bg = c.grey[600] },

  QuickFixLine = { fg = c.blue[600] },

  SpecialKey = { fg = c.grey[600] },
  ToolbarButton = { fg = c.bg[200], bg = c.blue[900] },

  Directory = { fg = c.blue[600] },
  NonText = { fg = c.grey[600] },
  debugPC = { fg = c.bg[200], bg = c.cyan[600] },
  debugBreakpoint = { fg = c.bg[200], bg = c.red[600] },
  Ignore = { fg = c.cyan[600], bg = c.bg[200], bold = true },
}

hl.syntax = {
  String = { link = "@string" },
  Character = { link = "@character" },
  Variable = { link = "@variable" },
  Float = { link = "@float" },
  Number = { link = "@number" },
  Boolean = { link = "@boolean" },
  Debug = { link = "@debug" },
  Type = { link = "@type" },
  Structure = { link = "@constant" },
  StorageClass = { link = "@storageclass" },
  Identifier = { link = "@field" },
  Constant = { link = "@constant" },
  PreProc = { link = "@preproc" },
  PreCondit = { link = "@preproc" },
  Include = { link = "@include" },
  Keyword = { link = "@keyword" },
  Define = { link = "@define" },
  Typedef = { link = "@type.definition" },
  Exception = { link = "@exception" },
  Conditional = { link = "@conditional" },
  Repeat = { link = "@repeat" },
  Statement = { link = "@define" },
  Macro = { link = "@constant.macro" },
  Error = { link = "@error" },
  Label = { link = "@label" },
  Special = { link = "@string.special" },
  SpecialChar = { link = "@character.special" },
  Function = { link = "@function" },
  Operator = { link = "@operator" },
  Title = { link = "@text.title" },
  Tag = { link = "@tag" },
  Delimiter = { link = "@punctuation.delimiter" },
  Comment = { link = "@comment" },
  SpecialComment = { link = "@comment" },
  Todo = { link = "@todo" },
}

hl.treesitter = {
  ["@annotation"] = { fg = c.fg },
  ["@attribute"] = { fg = c.cyan[600] },
  ["@boolean"] = { fg = c.orange[600] },
  ["@character"] = { fg = c.fg },
  ["@character.special"] = { fg = c.fg },
  ["@comment"] = { fg = c.grey[600], italic = true },
  ["@conditional"] = { fg = c.purple[600] },
  ["@constant"] = { fg = c.yellow[600] },
  ["@constant.builtin"] = { fg = c.orange[600] },
  ["@constant.macro"] = { fg = c.orange[600] },
  ["@constructor"] = { fg = c.yellow[600] },
  ["@debug"] = { fg = c.grey[600] },
  ["@define"] = { fg = c.purple[600] },
  ["@error"] = { fg = c.red[600] },
  ["@exception"] = { fg = c.purple[600] },
  ["@field"] = { fg = c.red[600] },
  ["@float"] = { fg = c.green[300] },
  ["@function"] = { fg = c.blue[600] },
  ["@function.call"] = { fg = c.blue[600] },
  ["@function.builtin"] = { fg = c.cyan[600] },
  ["@function.macro"] = { fg = c.fg },
  ["@include"] = { fg = c.purple[600] },
  ["@keyword"] = { fg = c.purple[600] },
  ["@keyword.function"] = { fg = c.purple[600] },
  ["@keyword.operator"] = { fg = c.purple[600] },
  ["@keyword.return"] = { fg = c.purple[600] },
  ["@label"] = { fg = c.red[600] },
  ["@method"] = { fg = c.blue[600] },
  ["@method.call"] = { fg = c.blue[600] },
  ["@namespace"] = { fg = c.red[600] },
  ["@none"] = { fg = c.fg },
  ["@number"] = { fg = c.orange[600] },
  ["@operator"] = { fg = c.cyan[600] },
  ["@parameter"] = { fg = c.red[600] },
  ["@parameter.reference"] = { fg = c.fg },
  ["@preproc"] = { fg = c.purple[600] },
  ["@property"] = { fg = c.red[600] },
  ["@punctuation.delimiter"] = { fg = c.fg },
  ["@punctuation.bracket"] = { fg = c.yellow[900] },
  ["@punctuation.special"] = { fg = c.cyan[600] },
  ["@repeat"] = { fg = c.purple[600] },
  ["@storageclass"] = { fg = c.yellow[600] },
  ["@string"] = { fg = c.green[600] },
  ["@string.regex"] = { fg = c.orange[600] },
  ["@string.escape"] = { fg = c.red[600] },
  ["@string.special"] = { fg = c.red[600] },
  ["@symbol"] = { fg = c.cyan[600] },
  ["@tag"] = { fg = c.red[600] },
  ["@tag.attribute"] = { fg = c.orange[600] },
  ["@tag.delimiter"] = { fg = c.grey[900] },
  ["@text"] = { fg = c.fg },
  ["@text.strong"] = { bold = true },
  ["@text.emphasis"] = { standout = true },
  ["@text.underline"] = { underline = true },
  ["@text.strike"] = { strikethrough = true },
  ["@text.title"] = { fg = c.yellow[600] },
  ["@text.literal"] = { fg = c.green[300] },
  ["@text.uri"] = { fg = c.cyan[600], underline = true },
  ["@text.math"] = { fg = c.yellow[600] },
  ["@text.reference"] = { fg = c.fg },
  ["@text.environment"] = { fg = c.fg },
  ["@text.environment.name"] = { fg = c.fg },
  ["@text.note"] = { fg = c.grey[600] },
  ["@text.warning"] = { fg = c.orange[600] },
  ["@text.danger"] = { fg = c.red[600] },
  ["@todo"] = { fg = c.cyan[600] },
  ["@type"] = { fg = c.yellow[600] },
  ["@type.builtin"] = { fg = c.yellow[600] },
  ["@type.qualifier"] = { fg = c.purple[900] },
  ["@type.definition"] = { fg = c.yellow[600] },
  ["@variable"] = { fg = c.red[600] },
  ["@variable.builtin"] = { fg = c.yellow[600] },
  ["@inlayhint"] = { italic = true, bg = c.bg[300], fg = c.bg[600] },
  -- Semantic
  ["@class"] = { fg = c.orange[600] },
  ["@struct"] = { fg = c.orange[600] },
  ["@enum"] = { fg = c.yellow[600] },
  ["@enumMember"] = { fg = c.yellow[600] },
  ["@event"] = { fg = c.cyan[600] },
  ["@interface"] = { fg = c.yellow[600] },
  ["@modifier"] = { fg = c.cyan[600] },
  ["@regexp"] = { fg = c.orange[900] },
  ["@typeParameter"] = { fg = c.yellow[600] },
  ["@decorator"] = { fg = c.cyan[600] },
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

hl.langs.bash = { ["@parameter.bash"] = { fg = c.fg } }

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

hl.langs.typescript = {
  -- ["@decorator.typescript"] = { fg = c.fg },
}

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
  HopNextKey = { fg = c.bg[100], bg = c.yellow[600], bold = true },
  HopNextKey1 = { fg = c.bg[100], bg = c.orange[600], bold = true },
  HopNextKey2 = { fg = c.bg[100], bg = c.yellow[600], bold = true },
  HopUnmatched = { fg = c.none, bg = c.none },
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

hl.plugins.neotree_nvim = {
  NeoTreeIndentMarker = { fg = c.bg[400] },
  NeoTreeExpander = { fg = c.bg[500] },
  NeoTreeBufferNumber = {},
  NeoTreeCursorLine = {},
  NeoTreeDimText = { fg = c.bg[500] },
  NeoTreeDirectoryIcon = {},
  NeoTreeDirectoryName = {},
  NeoTreeDotfile = { fg = c.bg[700] },
  NeoTreeFadeText1 = {},
  NeoTreeFadeText2 = {},
  NeoTreeFileIcon = {},
  NeoTreeFileName = {},
  NeoTreeFileNameOpened = {},
  NeoTreeFilterTerm = {},
  NeoTreeFloatBorder = {},
  NeoTreeFloatTitle = {},
  NeoTreeModified = { fg = c.file.change },
  NeoTreeGitAdded = { fg = c.file.add },
  NeoTreeGitConflict = { fg = c.file.conflict },
  NeoTreeGitDeleted = { fg = c.file.delete },
  NeoTreeGitIgnored = { fg = c.file.ignored },
  NeoTreeGitModified = { fg = c.file.modified },
  NeoTreeGitRenamed = { fg = c.file.renamed },
  NeoTreeGitUntracked = { fg = c.file.untracked },
  NeoTreeSymbolicLinkTarget = { fg = c.file.symbolic_link },
  NeoTreeHiddenByName = {},
  NeoTreeNormal = {},
  NeoTreeNormalNC = {},
  NeoTreeRootName = {},
  NeoTreeTitleBar = {},
}

hl.plugins.telescope = {
  TelescopeMatching = { fg = c.green[300] },
  TelescopeSelectionCaret = { fg = c.yellow[600] },

  TelescopeBorder = {
    fg = c.bg[100],
    bg = c.bg[100],
  },

  TelescopePromptBorder = {
    fg = c.bg[100],
    bg = c.bg[100],
  },

  TelescopePromptNormal = {
    fg = c.white,
    bg = c.bg[100],
  },

  TelescopePromptPrefix = {
    fg = c.yellow[600],
    bg = c.bg[100],
  },

  TelescopeNormal = { bg = c.bg[200] },

  TelescopePreviewTitle = {
    fg = c.bg[100],
    bg = c.green[600],
  },

  TelescopePromptTitle = {
    fg = c.bg[100],
    bg = c.red[600],
  },

  TelescopeResultsTitle = {
    fg = c.bg[100],
    bg = c.bg[100],
  },

  TelescopeResultsNormal = {
    bg = c.bg[100],
  },

  TelescopePreviewBorder = { fg = c.grey[100] },

  TelescopeSelection = { bg = c.bg[300], fg = c.white },

  TelescopeResultsDiffAdd = {
    fg = c.green[600],
  },

  TelescopeResultsDiffChange = {
    fg = c.yellow[600],
  },

  TelescopeResultsDiffDelete = {
    fg = c.red[600],
  },
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

hl.plugins.noice = {
  NoiceLspProgressTitle = { fg = c.green[300] },
  NoiceLspProgressClient = { fg = c.orange[300] },
  NoiceLspProgressSpinner = { fg = c.yellow[300] },
  NoiceMini = { link = "NormalFloat" },
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

hl.plugins.hlslens = {
  HlSearchNear = { link = "IncSearch" },
  HlSearchLens = { link = "WildMenu" },
  HlSearchLensNear = { link = "IncSearch" },
  HlSearchFloat = { link = "IncSearch" },
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
