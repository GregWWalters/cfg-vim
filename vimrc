" configuration file for vim

" {{{ Basic editor settings
set modeline modelines=3     " read settings from top/bottom 3 lines of file
set nocompatible             " Use Vim defaults instead of 100% vi compatibility
set backspace=2              " more powerful backspacing
set noet                     " do not expand tabs to spaces
set nojs                     " use single spaces on joined lines
set tabstop=2                " size of a hard tabstop
set shiftwidth=2             " size of an indent
set softtabstop=2            " sets the number of columns for a tab
set smartindent              " syntax-aware auto-indent
set linebreak list           " soft word wrapping
set number                   " turn line numbers on
set ruler                    " show line and column
set tw=78                    " 80 chars text width
set scrolloff=4              " show 8 lines around cursor when scrolling
set lazyredraw               " improve performance
set title                    " set vim set the terminal window title
" set clipboard^=unnamed,unnamedplus " set default register to system clipboard
set grepprg=grep\ -nH\ $*    " set grep call to show filenames and line numbers
" set showmatch              " briefly jump to matching bracket on insert
set nohlsearch               " don't highlight all search results
set incsearch                " show where a search pattern matches as it is typed
set nospell                  " turn off spellcheck
set wildmode=list,full       " List all matches without completing, then each full match set wildmenu
set ignorecase smartcase     " ignore case unless pattern has uppercase chars
set noerrorbells             " turns off audible error bell
" set visualbell             " flashes screen for error bell
set splitbelow splitright    " open new splits below or to the right
let g:netrw_liststyle=3      " 0:thin 1:long 2:wide 3:tree
let g:netrw_list_hide='.*\.swp$'

" {{{ Syntax, Filetypes, Plugins
filetype on
filetype plugin on
filetype plugin indent on
syntax enable
" }}}

" {{{ ctags optimization
set autochdir
set tags=tags;
" }}}

" | {{{ Change the default text-search program
if executable("rg")
  set grepprg=rg\ --vimgrep\ --no-heading
  set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" | }}}

" | {{{ Use rg with fzf.vim
command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \   'rg --column --line-number --no-heading --color=always --ignore-case '.shellescape(<q-args>), 1,
      \   <bang>0 ? fzf#vim#with_preview('up:60%')
      \           : fzf#vim#with_preview('right:50%:hidden', '?'),
      \   <bang>0)

nnoremap <C-p>a :Rg
" | }}}

" | {{{ Use the same symbols as TextMate for tabstops and EOLs
set showbreak=↪\
set listchars=tab:→\ ,eol:↲,nbsp:␣,trail:•,extends:⟩,precedes:⟨
" | }}}
"
" | {{{ Folding
if empty(&foldmethod)
	set foldmethod=manual
endif
" TODO: try to set for filetypes where no ftplugin already handles it
" ref: https://vim.fandom.com/wiki/Syntax_folding_of_Vim_script://vim.fandom.com/wiki/Syntax_folding_of_Vim_scripts
" | }}}

" | {{{ Format options
set fo=croqn2lj "ta
"   t: auto-wrap text using text-width (good for text, bad for code)
"   c: automatically insert comment leader
"   r: automatically insert the comment leader after <Enter> in Insert mode
"   o: automatically insert the comment leader after 'O' in Normal mode
"   q: allow formatting of comments with "gq"
"   a: automatic formatting of paragraphs when text is inserted or deleted
"   n: recognize numbered lists
"   2: use the indent of the second line of a paragraph for the rest of the
"      paragraph
"   l: lines longer than 'textwidth' when insert is started are not
"      automatically formatted
"   j: remove comment leader when joining lines
" | }}}

" }}}

" {{{ Highlight text beyond 80 columns
" highlight OverLength ctermbg=darkgrey ctermfg=white guibg=#592929
" match OverLength /\%>80v.\+/
" }}}

" {{{ Mappings
map <F5> :setlocal spell! spelllang=en_us<CR>
" }}}

" {{{ Autocommands

" strip trailing whitespace before saving
autocmd BufWritePre * %s/\s\+$//e

" Don't reformat a block on insert/delete for markdown files (breaks lists)
autocmd Filetype pandoc,markdown,asciidoc
			\ setlocal tw=78 formatoptions+=t formatoptions-=a fdls=99 fdl=99

" Set foldmethod for JSON files
autocmd Filetype json setlocal foldmethod=syntax fdls=2 fdl=2

" Set foldmethod for Go files
autocmd Filetype go setlocal foldmethod=syntax fdls=2 fdl=2

" Highlight section MARKs
augroup sectionMarks
	autocmd Syntax * call g:MarkSections()
	highlight sectionLine ctermbg=darkgray ctermfg=white guibg=darkgray guifg=white
augroup END

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup

" Don't write backup file if vim is being called by 'chpass'
au BufWrite /private/etc/pw.* set nowritebackup

" }}}

" {{{ enable the mouse
if has('mouse')
	set mouse=a
	if !has('nvim')
		set ttymouse=xterm2
	endif
endif
" }}}

" {{{ Functions

" | {{{ Get list of available colorschemes
" TODO: also read from pack/themes/opt/*/colors
function! s:GetColorSchemes()
	return uniq(sort(map(
				\ globpath(&runtimepath, "colors/*.vim", 0, 1),
				\ 'fnamemodify(v:val, ":t:r")'
				\ )))
endfunction
" | }}}

" | {{{ Try to match terminal background
function! g:MatchTermBG()
	if !empty($TERM_BG_LIGHT) || $TERM_BG ==? "light"
		set background=light
	elseif !empty($TERM_BG_DARK) || $TERM_BG ==? "dark"
		set background=dark
	endif
endfunction
" | }}}

" | {{{ Pick a colorscheme
function! g:AutoColorscheme()
	let l:background = &background
	let l:schemes = s:GetColorSchemes()
	if $TERM_THEME ==? 'solarized' && index(l:schemes, 'solarized') >= 0
		colorscheme solarized
	elseif index(l:schemes, $TERM_THEME) >= 0
		colorscheme $TERM_THEME
	else
		" degrade Solarized colorscheme if not using Solarized pallette in terminal
		" let g:solarized_termcolors=256
		" set t_Co=256 " force vim to 256 colors
		" colorscheme solarized
		if l:background ==# "light"
			colorscheme peachpuff
		elseif l:background ==# "dark"
			colorscheme gruvbox
		endif
	endif
	let &background = l:background
endfunction
" | }}}

" | {{{ Compare changes in buffer against latest save
function! s:DiffWithSaved()
	let filetype=&ft
	diffthis
	vnew | r # | normal! 1Gdd
	diffthis
	exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()
" | }}}

" | {{{ Highlight sections MARKs
function! g:MarkSections()
	if !empty(&commentstring)
		let b:sectionMarkPattern = substitute(&commentstring, '%s', '\s*\(MARK\|SECTION\):', '')
		let b:sectionLinePattern = '`^' .. b:sectionMarkPattern .. '.*`'
		let b:sectionFoldStart = '`^' .. b:sectionMarkPattern .. '.*$\zs`'
		let b:sectionFoldEnd = '`\ze\(^' .. b:sectionMarkPattern .. '.*\)\|\%$`'
		execute 'syntax match sectionMark `^' .. b:sectionMarkPattern .. '` transparent contained conceal cchar=§'
		execute 'syntax match sectionLine ' .. b:sectionLinePattern .. ' contains=sectionMark transparent fold'
		execute 'syntax region sectionFold start=' .. b:sectionFoldStart .. ' end=' .. b:sectionFoldEnd .. ' transparent fold'
	endif
endfunction
" | }}}

" | {{{ Draw box around text
function! g:PutInBox(eChar = '#', bWidth = 80, margin = 1) range abort
	" TODO: re-draw box if it's already drawn

	" TODO: does 'put' work or do I need append?
	" call append(a:firstline, repeat('a:eChar',a:bWidth))
	exec a:firstline . 'put! =' . repeat(a:eChar,a:bWidth))

	let l:index = a:firstline
	while l:index <= a:lastline
		call setline(l:index,
			\ substitute(getline(l:index), '^\(.*\)$',
				\ a:eChar.' \1\=repeat(' ',a:bWidth-4-virtcol('$'))'))
		let l:index += 1
	endwhile

	" call append(a:lastline, repeat('a:eChar',a:bWidth))
	exec a:lastline . 'put =' . repeat(a:eChar,a:bWidth))
	return
endfunction
" | }}}

" }}}

" {{{ Colorscheme
call g:MatchTermBG()
call g:AutoColorscheme()
" }}}

" {{{ Apply custom templates
if has ("autocmd") && !exists("templates_loaded")
	augroup templates
		let templates_loaded = 1
		augroup CODEOWNERS  " Use .github/CODEOWNERS template
			autocmd BufNewFile **/.github/CODEOWNERS 0r ++bin ~/.vim/templates/skeleton.CODEOWNERS
			autocmd BufNewFile,BufReadPost **/.github/CODEOWNERS setlocal filetype=conf
		augroup END
	augroup END
endif
" }}}

" {{{ User Plugin Options

" | {{{ JavaScript
if !exists("javascript_opts_loaded")
	augroup javascript_opts
		autocmd!
		autocmd FileType javascript setlocal
					\ foldmethod=syntax foldlevelstart=2 foldlevel=2
		autocmd FileType javascript setlocal conceallevel=1
		\ | let g:javascript_plugin_jsdoc                      = 1
		\ | let g:javascript_conceal_function                  = "ƒ"
		\ | let g:javascript_conceal_null                      = "ø"
		\ | let g:javascript_conceal_this                      = "@"
		\ | let g:javascript_conceal_return                    = "⇚"
		\ | let g:javascript_conceal_undefined                 = "¿"
		\ | let g:javascript_conceal_NaN                       = "ℕ"
		\ | let g:javascript_conceal_prototype                 = "¶"
		\ | let g:javascript_conceal_static                    = "•"
		\ | let g:javascript_conceal_super                     = "Ω"
		\ | let g:javascript_conceal_arrow_function            = "⇒"
		\ | let g:javascript_conceal_noarg_arrow_function      = "🞅"
		\ | let g:javascript_conceal_underscore_arrow_function = "🞅"
	augroup END
endif
" | }}}

" | {{{ JSX
let g:jsx_pragma_required = 1
" | }}}

" | {{{ EditorConfig
let g:EditorConfig_preserve_formatoptions = 1
let g:EditorConfig_max_line_indicator = "exceeding" " [line, fill, exceeding, none]
" | }}}

" | {{{ TableMode
" For Markdown-compatible tables:
let g:table_mode_corner="|"
" For ReST-compatible tables
" let g:table_mode_corner="+"
" let g:table_mode_corner_corner="+"
" let g:table_mode_header_fillchar="="
" | }}}

" | {{{ NERDTree
let NERDTreeShowHidden = v:true
let NERDTreeSortHiddenFirst = v:true
" | }}}

" | {{{ Dadbod
" let g:db_ui_save_location = '~/.vimdbs'
" | }}}

" }}}

" {{{ Other VIM

" | {{{ GVim settings
if has ('gui_running')
	set guifont=FiraCode-Regular:h12
	colorscheme macvim
endif
" | }}}

" | {{{ NVim settings
if has('nvim')
	" set neovim-only options
	" set bg=dark
endif
" | }}}

" }}}

" vim:fdm=marker fmr={{{,}}} fdls=0 fdl=0
