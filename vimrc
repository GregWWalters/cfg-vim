" configuration file for vim
set modeline modelines=3

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible        "  Use Vim defaults instead of 100% vi compatibility
set backspace=2         "  more powerful backspacing
set noet                "  do not expand tabs to spaces
" joinspaces            "  use two spaces after terminating punctuation (.!?) when joining lines
" nojs                  "  use single spaces on joined lines
set tabstop=2           "  size of a hard tabstop
set shiftwidth=2        "  size of an indent
set softtabstop=2       "  sets the number of columns for a tab
set smartindent         "  syntax-aware auto-indent
" set wrap
set linebreak list      "  soft word wrapping
set number              "  turn line numbers on
set ruler
set tw=80               "  80 chars text width
set fo+=t               "  hard wrap text
" set nohls             "  don't highlight search terms
set lazyredraw          "  improve performance
set title               "  set vim set the terminal window title
set clipboard^=unnamed  "  set default register to system clipboard
" strip trailing whitespace before saving
autocmd BufWritePre * %s/\s\+$//e

" enable the mouse
if has('mouse')
	set mouse=a
	if !has('nvim')
		set ttymouse=xterm2
	endif
endif

filetype on
filetype plugin on
filetype plugin indent on
syntax enable           " highlight syntax
set grepprg=grep\ -nH\ $*
set showmatch
set incsearch
set foldmethod=syntax foldlevel=99
set nospell

" fzf and rg search
" set rtp+=/usr/local/opt/fzf
" Default fzf layout
" - down / up / left / right
" let g:fzf_layout = { 'down': '~40%' }
" Replace the default dictionary completion with fzf-based fuzzy completion
" inoremap <expr> <c-x><c-k> fzf#complete('cat /usr/share/dict/words')

" Options for vim-table-mode plugin
" For Markdown-compatible tables:
let g:table_mode_corner="|"
" For ReST-compatible tables
" let g:table_mode_corner="+"
" let g:table_mode_corner_corner="+"
" let g:table_mode_header_fillchar="="

map <F5> :setlocal spell! spelllang=en_us<CR>

" colorscheme slate       " set color scheme
" degrade Solarized colorscheme if not using Solarized pallette in terminal
" let g:solarized_termcolors=256
" force vim to 256 colors
" set t_Co=256

set wildmode=list,full  " List all matches without completing, then each full match set wildmenu

set smartcase           " keep original lower/uppercase when replacing words (when ignorecase is on)
compiler gcc            " use gcc

set noerrorbells        " turns off audible error bell
" set visualbell          " flashes screen for error bell

" Use the same symbols as TextMate for tabstops and EOLs
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨

" Highlight text beyond 80 columns
" highlight OverLength ctermbg=darkgrey ctermfg=white guibg=#592929
" match OverLength /\%>80v.\+/

" Don't write backup file if vim is being called by "crontab -e"
" au BufWrite /private/tmp/crontab.* set nowritebackup " Don't write backup file if vim is being called by "chpass"
" au BufWrite /private/etc/pw.* set nowritebackup

autocmd Filetype aut setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab tw=0 fo=t
autocmd Filetype pandoc,markdown setlocal textwidth=80 formatoptions=t

" Compare changes in buffer against latest save
function! s:DiffWithSaved()
	let filetype=&ft
	diffthis
	vnew | r # | normal! 1Gdd
	diffthis
	exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" Apply custom templates
if has ("autocmd") && !exists("templates_loaded")
	augroup templates
		let templates_loaded = 1
		" Use .github/CODEOWNERS templateif has("autocmd")
		autocmd BufNewFile **/.github/CODEOWNERS 0r ++bin ~/.vim/templates/skeleton.CODEOWNERS
		autocmd BufNewFile,BufReadPost **/.github/CODEOWNERS setlocal filetype=conf
	augroup END
endif


" GVim settings
if has ('gui_running')
	set guifont=FiraCode-Regular:h12
	colorscheme macvim
endif

" NVim settings
if has('nvim')
	" set neovim-only options
	" set bg=dark
endif
