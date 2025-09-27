" =========================
" Core & Leader
" =========================
set encoding=utf-8
let mapleader = " "     " Space as <leader>

" =========================
" Plugins (vim-plug)
" =========================
call plug#begin()
" File tree & icons
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Sensible defaults
Plug 'tpope/vim-sensible'

" YAML/Ansible
Plug 'pearofducks/ansible-vim'

" CoC (LSP/Completion)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" QoL: comments/surround/git/which-key
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'liuchengxu/vim-which-key'

" Fuzzy finder (plus ripgrep integration if rg installed)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" =========================
" Search & Editing Ergonomics
" =========================
set ignorecase smartcase incsearch hlsearch
nnoremap <leader><space> :nohlsearch<CR>

" Clipboard & mouse (optional)
set clipboard=unnamedplus
set mouse=a

" Splits + window navigation
set splitbelow splitright
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Persistent undo
set undofile
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif
set undodir=~/.vim/undo

" UI polish
set number
set termguicolors
set scrolloff=5 sidescrolloff=5
set nowrap linebreak
set cursorline
set timeoutlen=400

" Performance / CoC niceties
set hidden
set nobackup nowritebackup
set updatetime=300
set shortmess+=c
set signcolumn=yes
set completeopt=menuone,noinsert,noselect

" =========================
" FZF shortcuts
" =========================
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>r  :Rg<CR>
nnoremap <leader>b  :Buffers<CR>

" WhichKey helper
nnoremap <silent> <leader>? :WhichKey '<Space>'<CR>

" =========================
" NERDTree behavior & mappings
" =========================
let g:NERDTreeShowHidden = 1
let g:NERDTreeRespectWildIgnore = 1
let g:NERDTreeQuitOnOpen = 1
let g:webdevicons_enable_nerdtree = 1

augroup my_startup
  autocmd!
  autocmd StdinReadPre * let s:std_in=1
  " Open NERDTree only on empty start, then focus the edit window
  autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | wincmd p | endif
augroup END

" Quit Vim if NERDTree is the only remaining window
augroup my_nerdtree_quit
  autocmd!
  autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
augroup END

" Toggle + Tabs
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>] :tabnext<CR>
nnoremap <leader>[ :tabprevious<CR>

" =========================
" YAML / Ansible
" =========================
augroup my_yaml
  autocmd!
  autocmd FileType yaml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 autoindent number
augroup END

augroup ansible_ftdetect
  autocmd!
  autocmd BufRead,BufNewFile */playbooks/*.yml,*/roles/*/tasks/*.yml,*/roles/*/handlers/*.yml,*/group_vars/*,*/host_vars/*,*playbook*.yml,*site*.yml
        \ setfiletype yaml.ansible
augroup END

" Lint after saving YAML/Ansible (requires ansible-lint in PATH)
" autocmd BufWritePost *.yml,*.yaml :CocCommand ansible.executeLint
" Required by coc-ansible
let g:coc_filetype_map = { 'yaml.ansible': 'ansible' }

" =========================
" CoC: Extensions & Keymaps
" =========================
let g:coc_global_extensions = [
  \ '@yaegassy/coc-ansible', 'coc-yaml',
  \ 'coc-pyright', 'coc-json',
  \ 'coc-snippets', 'coc-pairs'
  \ ]

" Accept completion with Enter when pum visible; otherwise newline
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
" Navigate completion with Tab / Shift-Tab
inoremap <silent><expr> <Tab>   coc#pum#visible() ? coc#pum#next(1) : "\<Tab>"
inoremap <silent><expr> <S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<S-Tab>"

" LSP-like navigation
nmap gd <Plug>(coc-definition)
nmap gr <Plug>(coc-references)
nmap gy <Plug>(coc-type-definition)
nmap gi <Plug>(coc-implementation)

" Hover / rename / code actions / diagnostics
nnoremap K :call CocActionAsync('doHover')<CR>
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction)
nmap [d <Plug>(coc-diagnostic-prev)
nmap ]d <Plug>(coc-diagnostic-next)

" Highlight symbol under cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" =========================
" Yank highlight (Neovim only)
" =========================
augroup yank_highlight
  autocmd!
  if has('nvim')
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  endif
augroup END

" =========================
" Wildignore & colors
" =========================
set wildignore+=*.o,*.pyc,*.class,node_modules/**,dist/**,build/**
syntax on
colorscheme desert

" FOR LINUX GUI ONLY:
" set guifont=DroidSansMono\ Nerd\ Font\ 11

