local debug = {}
local conf = require("doodleVim.modules.debug.config")

debug['mfussenegger/nvim-dap'] = {
  opt = true,
  setup = function()
    require("doodleVim.utils.defer").packer_defer_load("nvim-dap", 1000)
  end,
  config = conf.dap
}

debug['rcarriga/nvim-dap-ui'] = {
  after = "nvim-dap",
  config = conf.dapui
}

return debug