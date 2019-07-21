
function notes#version()
    echom "version " . g:notes_version
endfunction


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

