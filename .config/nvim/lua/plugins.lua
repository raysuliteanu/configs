return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    use 'williamboman/mason.nvim'    
    use 'williamboman/mason-lspconfig.nvim'

    -- color schemes
    use "folke/tokyonight.nvim"
    use "ellisonleao/gruvbox.nvim"
    use "joshdick/onedark.vim"

    -- rust plugins...
    
    use 'neovim/nvim-lspconfig' 
    use 'simrat39/rust-tools.nvim'
    
    -- Completion framework:
    use 'hrsh7th/nvim-cmp' 

    -- LSP completion source:
    use 'hrsh7th/cmp-nvim-lsp'

    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip'                             
    
    use 'nvim-treesitter/nvim-treesitter'

    -- git
    -- use 'lewis6991/gitsigns.nvim'
    use "nvim-lua/plenary.nvim"
    use 'nvim-tree/nvim-web-devicons'
    use {
        'tanvirtin/vgit.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        }
    }

--    use 'puremourning/vimspector'

    if packer_bootstrap then
        require('packer').sync()
    end

end)


