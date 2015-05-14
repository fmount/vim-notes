" notes.vim -  A vim plugin to take notes easily
" Mantainer: bxor99
" Version: 0.01-alpha
" AutoInstall: notes.vim
" ====== Enjoy ======
"

if exists('g:loaded_notes') || &cp
	finish
endif

let g:loaded_notes = 0

"For security reasons..
if v:version < 702
	echomsg 'notes: You need at least Vim 7.2'
	finish
endif

if !exists('g:notes_folder')
	let g:notes_folder = "~/.notes"
endif

if !exists("g:notes_autosave")
	let g:notes_autosave = 0
	let g:notes_autosave_time = 10 "seconds
endif


" window handling

if !exists('g:notes_win_autohide')
	let g:notes_win_autohide = &hidden
endif

if !exists('g:notes_win_height')
	let g:notes_win_height = 0.5
endif
if !exists('g:notes_win_top')
	let g:notes_win_top = 1
endif

if !exists('g:notes_winnr')
	let g:notes_winnr = -1
endif


"Commands definition
command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist, NoteList call notes#list()
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! NoteAutoSaveToggle :call notes#autosave_toggle()

"Navigate your note buffers
command! -nargs=* NNEXT call notes#navig("next",'^\(.*note$\)\@!.*$')
command! -nargs=* PPREVIOUS call notes#navig("previous",'^\(.*note$\)\@!.*$')

command! -complete=customlist,notes#navigate -nargs=1 ScratchNote call notes#open(<f-args>,<f-args>)
command! -complete=customlist,notes#navigate -nargs=0 ScratchOpen call notes#open(-1,-1)
command! -bang -nargs=0 ScratchClose call notes#close(0)


"DEBUG COMMANDS
"command! -nargs=* BLIST call notes#blist_open()
"SKIP ALL NOTES FILES
"command! -nargs=* NEXT call notes#navig("next",'\^*.note$')
"command! -nargs=* PREVIOUS call notes#navig("previous",'\^*.note$')


augroup window_handling
	autocmd WinEnter * if winnr() == notes#FindWinNumID('note') | nnoremap <C-N> :NNEXT <CR> | endif
	autocmd WinEnter * if winnr() == notes#FindWinNumID('note')  | nnoremap <C-P> :PPREVIOUS <CR> | endif
	autocmd WinLeave * if winnr() == notes#FindWinNumID('note') | nnoremap <C-N> :bnext! <CR> | endif
	autocmd WinLeave * if winnr() == notes#FindWinNumID('note')  | nnoremap <C-P> :bprevious! <CR> | endif
augroup END


augroup bufferset
	autocmd!
	autocmd BufRead,BufNewFile *.note set filetype=markdown
	autocmd BufRead,BufNewFile *.note let b:notes_start_time=localtime()
	autocmd BufRead,BufNewFile	 *.* syntax on
	"Autosave settings
	autocmd CursorHold,BufRead *.note call notes#update_buffer()
	autocmd BufWritePre *.note let b:notes_start_time = localtime()
augroup END


nnoremap <leader>nv :call notes#open(-1,-1) <CR>
nnoremap <leader>nc :call notes#close(0)<CR>
