# Vim for YAML/Ansible + CoC (LSP) — Ready-to-Use Setup

A lightweight, productivity-focused Vim configuration for YAML/Ansible, Python, and general editing.
Features include:

* Sensible defaults (`vim-sensible`)
* File tree (`NERDTree`) + icons
* LSP/Autocomplete via `coc.nvim` (with Ansible, YAML, Python, JSON, snippets)
* Fuzzy finding with `fzf` (optional: `ripgrep`)
* Handy motions and quality-of-life mappings

> **Leader key**: Space (`<Space>`)

---

## Table of Contents

* [Prerequisites](#prerequisites)
* [Install vim-plug](#install-vim-plug)
* [Add the vimrc](#add-the-vimrc)
* [Install plugins](#install-plugins)
* [CoC: language extensions](#coc-language-extensions)
* [Ansible/YAML setup](#ansibleyaml-setup)
* [Keymaps & Usage](#keymaps--usage)
* [FAQ / Troubleshooting](#faq--troubleshooting)
* [Notes](#notes)

---

## Prerequisites

* **Vim 8.2+** or **Neovim 0.5+**
* **Node.js** (required by `coc.nvim`) — recommended **v16+**
* **fzf** (optional; auto-installs via plugin)
* **ripgrep** (`rg`, optional but recommended for super-fast `:Rg`)
* **Ansible** + **ansible-lint** (for best Ansible LSP/lint experience)
* A **Nerd Font** (optional, for devicons) — e.g., “DroidSansMono Nerd Font”

### Quick install hints

**macOS (Homebrew):**

```bash
brew install vim node fzf ripgrep ansible ansible-lint
# optional: fzf key-bindings
$(brew --prefix)/opt/fzf/install
```

**Ubuntu/Debian:**

```bash
sudo apt update
sudo apt install vim nodejs npm fzf ripgrep python3-pip
pip3 install --user ansible ansible-lint
```

**Fedora:**

```bash
sudo dnf install vim nodejs fzf ripgrep python3-pip
pip3 install --user ansible ansible-lint
```

---

## Install vim-plug

**Vim:**

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

**Neovim:**

```bash
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

---

## Add the vimrc

Create or overwrite `~/.vimrc` (for Neovim, use `~/.config/nvim/init.vim` and paste the same content):

```vim
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

" airline statusbar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
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

let g:airline_theme='simple'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'unique_tail'
" air-line
let g:airline_powerline_fonts = 1
let g:airline#extensions#whitespace#enabled = 0

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif


" airline tabline enable
let g:airline#extensions#tabline#enabled = 1

" airline symbols
let g:airline_symbols.whitespace = 'Ξ'

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''
```

---

## Install plugins

Open Vim and run:

```
:PlugInstall
```

Restart Vim/Neovim once the install completes.

---

## CoC: language extensions

This config sets:

```vim
let g:coc_global_extensions = [
  \ '@yaegassy/coc-ansible', 'coc-yaml',
  \ 'coc-pyright', 'coc-json',
  \ 'coc-snippets', 'coc-pairs'
  \ ]
```

`coc.nvim` will auto-install these on first start. If it doesn’t, install manually:

```
:CocInstall @yaegassy/coc-ansible coc-yaml coc-pyright coc-json coc-snippets coc-pairs
:CocRestart
```

> If you need `ansible`/`ansible-lint`, either install them via your package manager or run:
>
> ```
> :CocCommand ansible.builtin.installRequirementsTools
> ```

---

## Ansible/YAML setup

* Files under common Ansible paths (e.g., `roles/*/tasks/*.yml`, `group_vars/*`, `host_vars/*`, `*playbook*.yml`, `site.yml`) will be detected as `yaml.ansible`.

* Verify with:

  ```
  :echo &filetype
  ```

  You should see `yaml.ansible`.

* **Schema issues?** You can select or disable a schema per file:

  ```
  :CocCommand yaml.selectSchema
  ```

---

## Keymaps & Usage

### NERDTree

* Toggle: `<Space> n`
* Auto-opens on empty start; closes Vim if it’s the only remaining window.

### Tabs

* Jump to tab **1–9**: `<Space>1` … `<Space>9`
* Next/Prev tab: `<Space>]` / `<Space>[`

### FZF (fuzzy finding)

* Files: `<Space> ff`
* Git files: `<Space> fg`
* Ripgrep search: `<Space> r`
* Buffers: `<Space> b`

### Windows

* Move between splits: `Ctrl-h/j/k/l`
* Open splits: use `:split`, `:vsplit` (defaults put splits below/right)

### Search

* Smart case search (`ignorecase`, `smartcase`)
* Incremental search (`incsearch`)
* Clear highlights: `<Space> <Space>`

### CoC (LSP)

* Completion:

  * Show menu automatically; **Enter** confirms when visible
  * Navigate menu: **Tab** / **Shift-Tab**
* Go to definition/refs/type/impl: `gd`, `gr`, `gy`, `gi`
* Hover docs: `K`
* Rename symbol: `<Space> rn`
* Code actions: `<Space> ca`
* Diagnostics: `[d` / `]d`

---

## FAQ / Troubleshooting

**CoC not working?**

* Ensure Node.js is installed.
* Run `:CocInfo` to see status, `:CocList extensions` to confirm extensions are active.
* Try `:CocUpdate` then `:CocRestart`.

**Ansible validation/lint isn’t running.**

* Ensure `ansible` and `ansible-lint` are in your PATH, or run
  `:CocCommand ansible.builtin.installRequirementsTools`.
* Confirm buffer is `yaml.ansible`: `:echo &filetype`.

**Schema error like “YAML 768 / $ref cannot be resolved.”**

* Select a simpler/available schema or disable for the file:
  `:CocCommand yaml.selectSchema`.

**Icons not showing in NERDTree.**

* Install a Nerd Font and set it in your terminal.

**Clipboard not working (Linux)?**

* You may need `xclip` or `xsel` if running a minimal environment.

---

## Notes

* Works in both Vim and Neovim. For Neovim, you can copy this to `~/.config/nvim/init.vim`.
* The config prefers performance-friendly defaults (`updatetime=300`, `signcolumn=yes`, no backups) appropriate for LSP/popups.
* YAML indentation is enforced at 2 spaces; Ansible filetype detection is idempotent to avoid re-sourcing issues.

---

Happy hacking! If you hit any edge cases (schema quirks, proxy environments, etc.), open an issue with your OS/Vim/Node versions and any error messages.
