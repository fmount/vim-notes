" notes.vim -  A vim plugin to take notes easily
" Mantainer: fmount, saro
" Version: 1.0
" AutoInstall: notes.vim
" ====== Enjoy ======

"For security reasons check the vim version
if v:version < 702
	echomsg 'notes: You need at least Vim 7.2'
	finish
endif

"if exists('g:loaded_notes') || &cp
"	finish
"endif

if !exists('g:notes_folder')
	let g:notes_folder = "$HOME/.notes"
endif

if !exists('g:notes_template_autogen')
	let g:notes_template_autogen = 0
endif

if !exists('g:notes_template_path')
	" Setting defaults
	call notes#templates()
endif

if !exists('g:notes_autosave')
	let g:notes_autosave = 0
	let g:notes_autosave_time = 10 "seconds
endif

if !exists('g:notes_compiler')
	let g:notes_compiler = 'markdown'
endif

if !exists('g:notes_export_folder')
	let g:notes_export_folder = '~/.notes/md2html'
endif

if !exists('g:default_keymap')
    let g:default_keymap = 1
endif

"let g:loaded_notes = 0
let g:notes_version = '1.0'
"let g:default_keymap = 1

" Create a new item
nnore (note-new-cbox-inline) I[ ]<space>
inore (note-new-cbox-inline) <Esc>I[ ]<space>

" Create a new item below
nnore (note-new-cbox-below) $o[ ]<space>
inore (note-new-cbox-below) <Esc>$o[ ]<space>

" Create a new item above
nnore (note-new-cbox-above) $O[ ]<space>
inore (note-new-cbox-above) <Esc>$O[ ]<space>

augroup bufferset
	autocmd!
	autocmd BufRead,BufNewFile *.note set filetype=markdown
	autocmd BufRead,BufNewFile *.note if g:default_keymap | call notes#defaultkeymap() | endif
	autocmd BufRead,BufNewFile *.note let b:notes_start_time=localtime()
	autocmd BufNewFile *.note silent! execute '0r '.expand(g:notes_template_path)
	" parse special text in the templates after the read
	autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
	"Autosave settings
	autocmd CursorHold,BufRead *.note call notes#update_buffer()
	autocmd BufWritePre *.note let b:notes_start_time = localtime()
augroup END

command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! NoteList call notes#list()
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! NoteAutoSaveToggle :call notes#autosave_toggle()

