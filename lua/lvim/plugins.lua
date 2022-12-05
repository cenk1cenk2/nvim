return {
  { "wbthomason/packer.nvim" },
  { "nvim-lua/plenary.nvim" },
  {
    "rcarriga/nvim-notify",
    config = function()
      require("lvim.core.notify").setup()
    end,
    disable = not lvim.builtin.notify.active,
  },
  { "nvim-lua/popup.nvim" },
  { "Tastyep/structlog.nvim" },
  {
    "kyazdani42/nvim-web-devicons",
    disable = not lvim.use_icons,
  },
  { "MunifTanjim/nui.nvim" },
}
