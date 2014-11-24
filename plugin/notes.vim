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
"if v:version < 702
"	echomsg 'notes: You need at least Vim 7.2'
"	finish
"endif

if !exists('g:notes_folder')
	let g:notes_folder = "~/.notes"
endif

if !exists("g:auto_save")
	let g:auto_save = 0
endif

augroup autosave
	autocmd!
	autocmd BufRead,BufNewFile   *.note set filetype=markdown
	"autocmd BufEnter * silent! lcd %:p:h
	autocmd BufRead,BufNewFile   *.* syntax on
	au CursorHold * call notes#update_buffer()
augroup END


command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist, NoteList call notes#list()
"command! -complete=customlist,NavigateNotes -nargs=1 NoteDelete :echo 'Removing Note: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'Removed' : 'Failed') | bdelete!
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! AutoSaveToggle :call notes#autosave_toggle()

function notes#edit(filename)
     let l:dir =  expand(g:notes_folder)
     let l:filename = a:filename
     if(fnamemodify(expand(a:filename,'/'),':h')=="")
	if !isdirectory(l:dir)
		exe "silent !mkdir ".l:dir
	endif
	exe "edit ".l:dir."/".l:filename
     elseif(expand(g:notes_folder) != fnamemodify(expand(a:filename,'/'),':h'))
	let l:filename = fnamemodify(expand(a:filename, '/'),':t')
	exe "edit ".l:dir."/".l:filename
     else
	exe "edit ".l:filename
     endif	
endfunction

function notes#list()
	let l:dir = expand(g:notes_folder)
	execute ":Explore ".l:dir
endfunction

function notes#navigate(A,L,P)
	 return split(globpath(g:notes_folder, "*"), "\n")
endfunction


function notes#delete(...)
  if(exists('a:1'))
    let note=a:1
    if(expand(g:notes_folder) != fnamemodify(expand(note,'/'),':h'))
      echomsg "Working directory doesn't match"
      return -1 
    endif
  elseif ( &ft == 'help' )
    echohl Error
    echo "Cannot delete a help buffer!"
    echohl None
    return -1
  else
    let note=expand('%:p')
  endif
  let delStatus=delete(note)
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
	if(g:auto_save >= 1 && &filetype=="markdown")
		let was_modified = &modified
		silent! wa
		if(was_modified && !&modified)
			echomsg "(AutoSaved at " . strftime("%H:%M:%S") . ")"
		endif
	endif
endfunction

function notes#autosave_toggle()
	if g:auto_save >= 1
		let g:auto_save = 0
		echo "AutoSave is OFF"
	else
		let g:auto_save = 1
		echo "AutoSave is ON"
	endif
endfunction

