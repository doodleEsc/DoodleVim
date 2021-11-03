local ui = require("plugins.ui.config")
local tools = require("plugins.tools.config")
local completion = require("plugins.completion.config")
local editor = require("plugins.editor.config")
local debug = require("plugins.debug.config")

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)

  -- LSP AND COMPLETION {
	use {'neovim/nvim-lspconfig', event = 'InsertEnter', config = completion.nvim_lsp}
	use {'kabouzeid/nvim-lspinstall', after = 'nvim-lspconfig'}
	use {'jasonrhansen/lspsaga.nvim', branch='finder-preview-fixes', after = 'nvim-lspconfig'}
	use {'onsails/lspkind-nvim', opt = true, after = 'nvim-lspconfig', config = completion.lspkind_nvim}

	use {'hrsh7th/nvim-cmp', event = 'InsertEnter', config = completion.nvim_cmp}
	use {'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp'}
	use {'hrsh7th/cmp-buffer', after = 'nvim-cmp'}
	use {'hrsh7th/cmp-path', after = 'nvim-cmp'}
	use {'tzachar/cmp-tabnine', after = 'nvim-cmp', run='./install.sh'}
	use {'hrsh7th/vim-vsnip', after = 'nvim-cmp'}
	use {'hrsh7th/vim-vsnip-integ', after = 'nvim-cmp'}
	use {'hrsh7th/cmp-vsnip', after = 'nvim-cmp'}
	use {'rafamadriz/friendly-snippets', after = 'nvim-cmp'}

	-- snoictemplate
	use {'mattn/vim-sonictemplate',
		cmd = 'Template',
	 	ft = {'go','python','rust','markdown'},
	 	config = completion.vim_sonictemplate,
	}
  -- }

  -- DEBUG {
  	-- nvim-dap
	use {'mfussenegger/nvim-dap', keys = {{"n","<F5>"}, {"n", "<F9>"}}, config = debug.dap}
	use {'rcarriga/nvim-dap-ui', 
		after = "nvim-dap",
		requires = {"mfussenegger/nvim-dap"},
		config = debug.dapui}
	use {'theHamsta/nvim-dap-virtual-text',
		after = "nvim-dap",
		requires = {"mfussenegger/nvim-dap"},
		setup = function() vim.g.dap_virtual_text = true end}
  -- }

  -- UI {
	-- treesitter
	use {'nvim-treesitter/nvim-treesitter', event = 'BufRead', config = ui.treesitter}
	use {'p00f/nvim-ts-rainbow', after = 'nvim-treesitter'}

	-- statusline
	use {'glepnir/galaxyline.nvim', branch = 'main', config = ui.galaxyline, requires = {'kyazdani42/nvim-web-devicons'}}

	-- colorizer
	use {'norcalli/nvim-colorizer.lua', ft={"lua", "vim", "markdown"}, config = function() require('colorizer').setup() end}

	-- tabline
	use {'romgrk/barbar.nvim', requires = {'kyazdani42/nvim-web-devicons'}, event = 'BufNew', config = ui.barbar}

  -- }

  -- EDITOR {

	use {'tyru/caw.vim', keys={'n','<Leader>c'},config = editor.caw}

	use {'easymotion/vim-easymotion', keys={"n","<Leader>s"}, config = editor.easymotion}

	use {'junegunn/vim-easy-align', keys={{"n","ma"},{"x","ma"}}, config=editor.easyalign}
	
	use {'andymass/vim-matchup', opt = true, setup = function() require("core.utils").packer_defer_load("vim-matchup", 2000) end}

	use {'windwp/nvim-autopairs', after = 'nvim-cmp', config = editor.autopairs}
  -- }

  -- TOOLS {
  	-- startuptime
  	use {'dstein64/vim-startuptime', cmd = 'StartupTime'}

	-- telescope
	use {'nvim-telescope/telescope.nvim', cmd = 'Telescope', config = tools.telescope,
		requires = {
		  {'nvim-lua/popup.nvim', opt = true},
		  {'nvim-lua/plenary.nvim',opt = true},
		  {'nvim-telescope/telescope-fzy-native.nvim',opt = true}
		}
	}
	
	-- nvim-tree
	use {'kyazdani42/nvim-tree.lua',
	  cmd = {'NvimTreeToggle','NvimTreeOpen'},
	  config = tools.nvim_tree,
	  requires = 'kyazdani42/nvim-web-devicons'
	}

	-- vista
	use {'liuchengxu/vista.vim', cmd = 'Vista', config = tools.vista}

	-- markdown-preview
	use {'iamcco/markdown-preview.nvim', ft = 'markdown', run = function() vim.cmd [[:call mkdp#util#install()]] end, config = tools.mkdp}

	-- translator
	use {'voldikss/vim-translator', cmd = {'TranslateW'}}

	-- floaterm
	use {'voldikss/vim-floaterm', cmd = {'FloatermToggle', 'FloatermNew'}, config = tools.floaterm}

	-- vim ascii draw
	use {'jbyuki/venn.nvim', cmd = {'VBox', 'VFill'}}

  -- }
end)
