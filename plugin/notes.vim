" notes.vim -  A vim plugin to take notes easily
" Mantainer: fmount
" Version: 1.0
" AutoInstall: notes.vim
" ====== Enjoy ======
"

if exists('g:loaded_notes') || &cp
	finish
endif

let g:loaded_notes = 0
let g:notes_version = '1.0'

"For security reasons..
"if v:version < 702
"	echomsg 'notes: You need at least Vim 7.2'
"	finish
"endif

if !exists('g:notes_folder')
	let g:notes_folder = "~/.notes"
endif

if !exists("g:notes_autosave")
	let g:notes_autosave = 0
	let g:notes_autosave_time = 10 "seconds
endif

augroup bufferset
	autocmd!
	autocmd BufRead,BufNewFile *.note set filetype=markdown
	autocmd BufRead,BufNewFile *.note let b:notes_start_time=localtime()
	"autocmd BufRead,BufNewFile   *.* syntax on
	"Autosave settings
	autocmd CursorHold,BufRead *.note call notes#update_buffer()
	autocmd BufWritePre *.note let b:notes_start_time = localtime()
augroup END


command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist, NoteList call notes#list()
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! NoteAutoSaveToggle :call notes#autosave_toggle()
