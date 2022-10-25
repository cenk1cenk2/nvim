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
  { "antoinemadec/FixCursorHold.nvim" }, -- Needed while issue https://github.com/neovim/neovim/issues/12587 is still open
  {
    "kyazdani42/nvim-web-devicons",
    disable = not lvim.use_icons,
  },
  { "MunifTanjim/nui.nvim" },
}
