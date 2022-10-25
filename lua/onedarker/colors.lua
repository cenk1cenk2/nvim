local colors = {
  none = nil,

  bg = {
    [100] = "#17191e",
    [200] = "#1e2127",
    [300] = "#22282f",
    [400] = "#38404b",
    [500] = "#4b5263",
    [600] = "#5c6370",
    [700] = "#7c8a9d",
    [800] = "#979eab",
    [900] = "#abb2bf",
  },

  cursor = "#6c778d",
  fg = "#abb2bf",
  white = "#efefef",
  black = "#121212",

  grey = {
    [300] = "#38404b",
    [600] = "#5c6370",
    [900] = "#b0b0b0",
  },

  red = {
    [300] = "#a04952",
    [600] = "#e06c75",
    [900] = "#ff7684",
  },

  orange = {
    [300] = "#a96b35",
    [600] = "#d19a66",
    [900] = "#efab5a",
  },

  yellow = {
    [300] = "#cbb07c",
    [600] = "#e5c07b",
    [900] = "#ead441",
  },

  green = {
    [300] = "#729C0C",
    [600] = "#98c379",
    [900] = "#d4ff79",
  },

  cyan = {
    [300] = "#2b6f77",
    [600] = "#56b6c2",
    [900] = "#87e6e2",
  },

  blue = {
    [300] = "#2c5372",
    [600] = "#61afef",
    [900] = "#93cfff",
  },

  purple = {
    [300] = "#8a3fa0",
    [600] = "#c678dd",
    [900] = "#f6a8ff",
  },

  magenta = {
    [300] = "#820668",
    [600] = "#a40778",
    [900] = "#f5169e",
  },
}

colors.diff = {
  add = "#1a311c",
  delete = "#2d0d1a",
  change = "#0b182d",
  text = "#0f2845",
}

colors.file = {
  add = colors.green[300],
  delete = colors.red[300],
  change = colors.blue[300],
  conflict = colors.red[600],
  modified = colors.yellow[300],
  renamed = colors.orange[300],
  untracked = colors.green[600],
  ignored = colors.grey[600],
  symbolic_link = colors.cyan[300],
}

return colors
