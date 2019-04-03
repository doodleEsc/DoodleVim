call plug#begin()
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

Plug 'filipekiss/ncm2-look.vim'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-ultisnips'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'Shougo/echodoc.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'ncm2/ncm2-vim-lsp'

Plug 'cinuor/vim-header'
Plug 'jiangmiao/auto-pairs'                                                      
Plug 'vim-airline/vim-airline'                                                   
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdcommenter'                                                  
Plug 'scrooloose/nerdtree'                                                       
Plug 'junegunn/vim-easy-align'                                                   
Plug 'iamcco/mathjax-support-for-mkdp'                                           
Plug 'iamcco/markdown-preview.vim'
Plug 'junegunn/fzf'
Plug 'sebdah/vim-delve'
Plug 'heavenshell/vim-pydocstring'
Plug 'terryma/vim-multiple-cursors'
call plug#end()

" neovim {
    set tabstop=4
    set signcolumn=yes
    set softtabstop=4
    set expandtab
    set shiftwidth=4
    set smarttab
    set colorcolumn=81
    set foldenable
    set foldmethod=syntax
    set foldcolumn=0
    setlocal foldlevel=1
    set foldlevelstart=99
    set termguicolors
    syntax enable
    colorscheme monokai-soda
    nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
    " hi Pmenu ctermfg=black ctermbg=gray  guibg=#444444
    " hi PmenuSel ctermfg=7 ctermbg=4 guibg=#555555 guifg=#ffffff
" }


" ncm2 {
    " enable ncm2 for all buffers
    autocmd BufEnter * call ncm2#enable_for_buffer()

    set completeopt=noinsert,menuone,noselect
    set shortmess+=c
    " Ctrl+C 退回到普通模式
    inoremap <C-c> <ESC>
    au TextChangedI * call ncm2#auto_trigger()

    " inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<CR>" : "\<CR>")

    " " Use <TAB> to select the popup menu:
    " inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    " inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" }


" look {
    let g:ncm2_look_enabled = 0

    function! Ncm2_look_trigger()
        if !exists("g:ncm2_look_enabled")
            let g:ncm2_look_enabled = 0
        endif
        if g:ncm2_look_enabled==0
            let g:ncm2_look_enabled = 1
        else
            let g:ncm2_look_enabled = 0
        endif
    endfunction

    nnoremap <leader>lo :call Ncm2_look_trigger()<CR>
" }

" ncm2-ultisnips {  
    " inoremap <silent> <expr> <C-k> ncm2_ultisnips#expand_or("\<CR>", 'n')
    inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')

    " imap <C-k> <Plug>(ultisnips_expand)
    " let g:UltiSnipsExpandTrigger            = "<Plug>(ultisnips_expand)"
    let g:UltiSnipsJumpForwardTrigger       = "<C-n>"
    let g:UltiSnipsJumpBackwardTrigger      = "<C-p>"
    " let g:UltiSnipsRemoveSelectModeMappings = 0
    " let g:snips_no_mappings = 1
    " let g:UltiSnipsSnippetDirectories = ['~/.config/nvim/UltiSnips', 'UltiSnips']
" }

" ncm2-go {
    " let g:ncm2_go#gocode_path = '/usr/local/bin/gocode'
" }
if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
    autocmd FileType go setlocal omnifunc=lsp#complete
endif
" " LSP {
    " set hidden
    " let g:LanguageClient_autoStart = 1
    " let g:LanguageClient_rootMarkers = {
        " \ 'go': ['.git', 'go.mod'],
        " \ }

    " let g:LanguageClient_serverCommands = {
        " \ 'python': ['pyls'],
        " \ 'go': ['gopls']
        " \ }


    " " let g:LanguageClient_completionPreferTextEdit = 0
    " " let g:LanguageClient_loggingFile = '/home/fanlz/lc.log'
    " " let g:LanguageClient_loggingLevel = 'DEBUG'
    " nnoremap <C-m> :call LanguageClient_contextMenu()<CR>
    " " Or map each action separately
    " nnoremap <silent> <leader>ho :call LanguageClient#textDocument_hover()<CR>
    " nnoremap <silent> <leader>gd :call LanguageClient#textDocument_definition()<CR>
    " nnoremap <silent> <leader>rn :call LanguageClient#textDocument_rename()<CR>
" " }

" echodoc {
    set noshowmode
    let g:echodoc#enable_at_startup = 1
    let g:echodoc#type = 'signature'
" }

" vim-airline {
    let g:airline_powerline_fonts = 1
    let g:airline_left_sep        = '>'
    let g:airline_right_sep       = '<'
    let g:airline_theme           = 'luna'
" }


" nerdcommenter {
    let g:NERDSpaceDelims = 1
" }


" vim-header {
    let g:header_auto_add_header = 0
    let g:header_field_timestamp_format = '%Y-%m-%d'
    let g:header_field_author = 'Fan Lizhou'
    let g:header_field_author_email = 'cokie@foxmail.com'
    map <F7> :AddHeader<CR>    
" }


" NerdTree {
        nnoremap <silent> <F2> :NERDTree<CR>
" }


" align {
        xmap ga <Plug>(EasyAlign)
        nmap ga <Plug>(EasyAlign)
" }

" windows {
        map <C-j> <C-w>j
        map <C-k> <C-w>k
        map <C-l> <C-w>l
        map <C-h> <C-w>h
" }

" markdown {
        nmap <silent> <F5> <Plug>MarkdownPreview
        imap <silent> <F5> <Plug>MarkdownPreview
        nmap <silent> <F6> <Plug>StopMarkdownPreview
        imap <silent> <F6> <Plug>StopMarkdownPreview
" }

" pydocstring {
        nmap <silent> <C-d> <Plug>(pydocstring)
" }

