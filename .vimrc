"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
"               ██╗   ██╗██╗███╗   ███╗██████╗  ██████╗
"               ██║   ██║██║████╗ ████║██╔══██╗██╔════╝
"               ██║   ██║██║██╔████╔██║██████╔╝██║
"               ╚██╗ ██╔╝██║██║╚██╔╝██║██╔══██╗██║
"                ╚████╔╝ ██║██║ ╚═╝ ██║██║  ██║╚██████╗
"                 ╚═══╝  ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" OPTIONS ---------------------------------------------------------------- {{{
" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
"set cursorline

" Highlight cursor line underneath the cursor vertically.
"set cursorcolumn

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Use space characters instead of tabs.
set expandtab

" Do not save backup files.
set nobackup

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" To get rid of the nasty ESC timeout delay (ttimeoutlen=-1) when a .vimrc
" file is provided.
" The default value should be set ttimeoutlen=100
set ttimeoutlen=100

" }}}

" PLUGINS ---------------------------------------------------------------- {{{

if has('win32')
        let $MYPLUGDIRECTORY = "~/vimfiles/plugged"
else
        let $MYPLUGDIRECTORY = "~/.vim/plugged"
endif

" vim-plug: A minimalist Vim plugin manager.
" https://github.com/junegunn/vim-plug
call plug#begin($MYPLUGDIRECTORY)
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
" Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
" Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
" Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
" Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'

" sensible.vim: a universal set of defaults that (hopefully) everyone can agree on.
" https://github.com/tpope/vim-sensible
Plug 'tpope/vim-sensible'

" Vim Polyglot: A collection of language packs for Vim.
" https://github.com/sheerun/vim-polyglot
Plug 'sheerun/vim-polyglot'

" sleuth.vim: Heuristically set buffer options
" https://github.com/tpope/vim-sleuth
Plug 'tpope/vim-sleuth'

" EditorConfig Vim Plugin
" https://github.com/editorconfig/editorconfig-vim
Plug 'editorconfig/editorconfig-vim'

" Vim Colors Solarized
" https://github.com/altercation/vim-colors-solarized
Plug 'altercation/vim-colors-solarized'

" fugitive.vim
" Fugitive is the premier Vim plugin for Git. Or maybe it's the premier Git plugin for Vim?
" Either way, it's 'so awesome, it should be illegal'. That's why it's called Fugitive.
" https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive'

" vim-visual-multi
" It's called vim-visual-multi in analogy with visual-block, but the plugin works mostly from normal mode.
" https://github.com/mg979/vim-visual-multi
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" Highlight, jump and resolve conflict markers quickly.
" https://github.com/rhysd/conflict-marker.vim
" ct, co, cn, cb (theirs, ours, none, both)
Plug 'rhysd/conflict-marker.vim'

" fzf/fzf.vim
" fzf is a general-purpose command-line fuzzy finder.
" https://github.com/junegunn/fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" GitHub Copilot is an AI pair programmer tool that helps you write code faster and smarter.
" Trained on billions of lines of public code, GitHub Copilot turns natural language prompts
" including comments and method names into coding suggestions across dozens of languages.
" Copilot.vim is a Vim/Neovim plugin for GitHub Copilot.
" https://github.com/github/copilot.vim
Plug 'github/copilot.vim'

" Call plug#end to update &runtimepath and initialize the plugin system.
" - It automatically executes `filetype plugin indent on` and `syntax enable`
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

" }}}

" COLOR SCHEMES ---------------------------------------------------------- {{{
set background=dark
" set background=light

if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif

" Vim Colors Solarized
" https://github.com/altercation/vim-colors-solarized
" let g:solarized_termcolors=256
" colorscheme solarized

" Selenized
" https://github.com/jan-warchol/selenized
colorscheme selenized
" let g:selenized_green_keywords=1

" }}}

" MAPPINGS --------------------------------------------------------------- {{{

" Mapleader will allow you set a key unused by Vim as the <leader> key.
" The leader key, in conjunction with another key, will allow you to create new shortcuts.
let mapleader = "\<space>"

" Toggle search highlighting by pressing \\
nnoremap <leader>\ :set hlsearch! hlsearch?<CR>

" Remove all trailing whitespaces
" https://idie.ru/posts/vim-modern-cpp/
nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

" Accessing Standard Library documentation using cppman, use JbzCppMan function
" https://idie.ru/posts/vim-modern-cpp/
au FileType cpp nnoremap <buffer>K :JbzCppMan<CR>

" Toggle Background Function
" https://github.com/altercation/vim-colors-solarized
call togglebg#map("<F5>")

" Fugitive Conflict Resolution
" https://medium.com/prodopsio/solving-git-merge-conflicts-with-vim-c8a8617e3633
nnoremap <leader>gd :Gvdiff<CR>
nnoremap gdh :diffget //2<CR>
nnoremap gdl :diffget //3<CR>

" Search for visually selected text
" https://vim.fandom.com/wiki/Search_for_visually_selected_text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" }}}

" VIMSCRIPT -------------------------------------------------------------- {{{

" Fix the difficult-to-read default setting for diff text highlighting.  The
" bang (!) is required since we are overwriting the DiffText setting. The highlighting
" for "Todo" also looks nice (yellow) if you don't like the "MatchParen" colors.
" https://stackoverflow.com/questions/2019281/load-different-colorscheme-when-using-vimdiff
highlight! link DiffText MatchParen

" This will enable code folding.
" Use the marker method of folding.
" https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" Man page viewer
" https://stackoverflow.com/questions/16740246/what-is-a-way-to-read-man-pages-in-vim-without-using-temporary-files
runtime ftplugin/man.vim

command! TrailingWhitespaceHighlightOn  call TrailingWhitespaceHighlightOn()
command! TrailingWhitespaceHighlightOff call TrailingWhitespaceHighlightOff()

" Removing trailing whitespaces
" https://idie.ru/posts/vim-modern-cpp/
function! TrailingWhitespaceHighlightOn() abort
    highlight TrailingWhitespaceHighlight ctermbg=red guibg=red

    augroup TrailingWhitespaceHighlight
        autocmd!
        match TrailingWhitespaceHighlight /\s\+$/
        autocmd InsertLeave * match TrailingWhitespaceHighlight /\s\+$/
        autocmd InsertEnter * match TrailingWhitespaceHighlight /\s\+\%#\@<!$/
        autocmd BufWinEnter * match TrailingWhitespaceHighlight /\s\+$/
        autocmd BufWinLeave * call clearmatches()
    augroup END
endfunction

function! TrailingWhitespaceHighlightOff() abort
    augroup TrailingWhitespaceHighlight
        autocmd!
    augroup END

    call clearmatches()
endfunction

function! TrailingWhitespaceHighlightToggle() abort
    if exists("g:trailing_whitespace_highlight")
        call TrailingWhitespaceHighlightOff()
        unlet g:trailing_whitespace_highlight
    else
        call TrailingWhitespaceHighlightOn()
        let g:trailing_whitespace_highlight = 1
    endif
endfunction

function! TrailingWhitespaceNext() abort
  " Search for trailing whitespace from the current line down
  call search('\s\+$', 'W') " 'W' = wrap around the end of file
endfunction

autocmd VimEnter * call TrailingWhitespaceHighlightOn()

" Do one search for trailing spaces, then n/N will cycle through
nnoremap <silent> <leader>w /\s\+$<CR>

" Accessing Standard Library documentation using cppman
" https://idie.ru/posts/vim-modern-cpp/
function! s:JbzCppMan()
    let old_isk = &iskeyword
    setl iskeyword+=:
    let str = expand("<cword>")
    let &l:iskeyword = old_isk
    execute 'Man ' . str
endfunction
command! JbzCppMan :call s:JbzCppMan()

" Delete all Git conflict markers
" Creates the command :GremoveConflictMarkers
" https://vi.stackexchange.com/questions/10534/is-there-a-way-to-take-both-when-using-vim-as-merge-tool
function! RemoveConflictMarkers() range
  echom a:firstline.'-'.a:lastline
  execute a:firstline.','.a:lastline . ' g/^<\{7}\|^|\{7}\|^=\{7}\|^>\{7}/d'
endfunction
"-range=% default is whole file
command! -range=% GremoveConflictMarkers <line1>,<line2>call RemoveConflictMarkers()

" }}}
