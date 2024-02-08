local colors = {
  none = nil,

  bg = {
    [100] = "#17191e",
    [200] = "#1e2127",
    [300] = "#22282f",
    [400] = "#2c333d",
    [500] = "#4b5263",
    [600] = "#5c6370",
    [700] = "#7c8a9d",
    [800] = "#979eab",
    [900] = "#abb2bf",
  },

  cursor = "#6c778d",
  fg = "#abb2bf",
  white = "#efefef",
  bright_white = "#ffffff",
  black = "#121212",

  grey = {
    [300] = "#38404b",
    [600] = "#5c6370",
    [900] = "#b0b0b0",
  },

  red = {
    [100] = "#2d1617",
    [300] = "#a04952",
    [600] = "#e06c75",
    [900] = "#fd969c",
  },

  orange = {
    [300] = "#b07335",
    [600] = "#d19a66",
    [900] = "#f1b862",
  },

  yellow = {
    [100] = "#2e2619",
    [300] = "#d3b051",
    [600] = "#e5c07b",
    [900] = "#ebcd8f",
  },

  green = {
    [100] = "#122b0a",
    [300] = "#729c0c",
    [600] = "#98c379",
    [900] = "#d4ff79",
  },

  cyan = {
    [100] = "#1a373a",
    [300] = "#2b6f77",
    [600] = "#56b6c2",
    [900] = "#87e6e2",
  },

  blue = {
    [100] = "#1d3448",
    [300] = "#4676ac",
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
    [900] = "#bb23a1",
  },
}

colors.diff = {
  add = colors.green[100],
  delete = colors.red[100],
  text = colors.blue[100],
  change = colors.yellow[100],
  add_bright = colors.green[600],
  delete_bright = colors.red[600],
  text_bright = colors.blue[600],
  change_bright = colors.cyan[600],
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
