" notes.vim -  A vim plugin to take notes easily
" Mantainers: fmount,saro
" Version: 1.0
" AutoInstall: notes.vim
" ====== Enjoy ======

" Print the current version
function notes#version()
	echom "version " . g:notes_version
endfunction

" This function is called when a buffer is created
" or opened and pushes some default keybindings for
" the plugin.
" Set 'g:default_keymap = 0' to turn off the default
" keybindings
function notes#defaultkeymap()
	" Add checkbox creating/marking key maps
	nmap <buffer> <Leader>[i (note-new-cbox-inline)
	imap <buffer> <Leader>[i (note-new-cbox-inline)
	nmap <buffer> <Leader>[o (note-new-cbox-below)
	imap <buffer> <Leader>[o (note-new-cbox-below)
	nmap <buffer> <Leader>[O (note-new-cbox-above)
	imap <buffer> <Leader>[O (note-new-cbox-above)
	nmap <buffer> <Leader>[x :call notes#toggle_checkbox(line('.'))<cr>
	" Fast Export function
	nmap <leader>[e :call notes#export() <cr>
endfunction

" Create a new note or open an existing one
function notes#edit(filename)
	let l:dir =  expand(g:notes_folder)
	let l:tmpfilename = a:filename

	"Check for file extention"
	let l:fileext = matchstr(l:tmpfilename, '\.\w*$')

	if (empty(l:fileext))
		let l:newext = '.note'
	 else
		let l:newext = ''
	endif

	" Create l:dir if not existing
	if !isdirectory(l:dir)
		exe "silent !mkdir " . l:dir
	endif

	" This is used when we don't pass any log
	if(fnamemodify(expand(a:filename, '/'), ':h') == "")
		exe "edit " . l:dir . "/" . a:filename . l:newext
	" This is used when we pass an absolute path
	elseif(expand(g:notes_folder) != fnamemodify(expand(a:filename, '/'), ':h'))
		let l:filename = fnamemodify(expand(a:filename, '/'), ':t')
		exe "edit " . l:dir . "/" . l:filename . l:newext
	else
		exe "edit " . a:filename . l:newext
	endif
endfunction

function notes#list()
	let l:dir = expand(g:notes_folder)
	execute ":Explore " . l:dir
endfunction

function notes#navigate(A,L,P)
	return split(globpath(g:notes_folder, "*"), "\n")
endfunction


function notes#delete(...)
	if(exists('a:1'))
		let note = a:1
		"Check for the working directory
		if(expand(g:notes_folder) != fnamemodify(expand(note, '/'), ':h'))
			echomsg "Working directory doesn't match"
			return -1
		endif
	elseif ( &ft == 'help' )
		echohl Error
		echo "Cannot delete a help buffer!"
		echohl None
		return -1
	else
		let note = expand('%:p')
	endif

	let delStatus = delete(note)

	if(delStatus == 0)
		echo "Deleted " . note
	else
		echohl WarningMsg
		echo "Failed to delete " . note
		echohl None
	endif
	return delStatus
endfunction


" Autosave for buffered notes
function notes#update_buffer()
	"echomsg "Time elapsed: ".(localtime()-b:notes_start_time) "DEBUG TIME
	let l:note_time_elapsed = localtime() - b:notes_start_time

	" check for the time elapsed, the value of the autosave variable and
	" the current file type (through the .note extension)
	if(matchstr(expand('%.t'),'\^*.note$') != "" && g:notes_autosave >= 1
				\&& l:note_time_elapsed >= g:notes_autosave_time)

		"Try to update the buffer if modified
		let was_modified = &modified
		silent! w

		if(was_modified && !&modified)
			echomsg "(AutoSaved at " . strftime("%H:%M:%S") . ")"
			let b:notes_start_time = localtime()
		endif
	endif
endfunction

" Enable and disable the autosave function for .note files
function notes#autosave_toggle()
	if g:notes_autosave >= 1
		let g:notes_autosave = 0
		echo "Notes AutoSave disabled"
	else
		let g:notes_autosave = 1
		echo "Notes AutoSave enabled"
	endif
endfunction

" Fill or clean the checkbox where the cursor is present
function notes#toggle_checkbox(linenr)
	if (empty(matchstr(getline(a:linenr), '^\s*\[\s\].*$')) == 0)
		:s/^\s*\[\s\]/\1[x]
	elseif (empty(matchstr(getline(a:linenr), '^\s*\[x\].*$')) == 0)
		:s/^\s*\[x\]/\1[ ]
	endif
endfunction

" Markdown2HTML export function
function notes#export()
	let l:dest_dir = expand(g:notes_export_folder)
	if executable(g:notes_compiler)
		" Create g:notes_export_folder if not existing
		if !isdirectory(l:dest_dir)
			call mkdir(l:dest_dir,'p')
		endif
		if(matchstr(bufname('%'),'\^*.note$') != "")
			echom system(g:notes_compiler . " " . bufname('%') . ">> " . g:notes_export_folder . "/" . expand('%:t:r') . '.html')
		else
			echom 'Provide a .note file'
		endif
	else
		echom "No " . g:notes_compiler . " found"
	endif
	echom "Note " . bufname('%') . " exported"
endfunction
