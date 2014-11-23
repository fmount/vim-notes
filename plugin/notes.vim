" notes.vim -  A vim plugin to take notes easily
" Mantainer: XXX
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
	"au BufEnter *   execute ":lcd " . expand("%:p:h")
	autocmd BufEnter * silent! lcd %:p:h
	autocmd BufRead,BufNewFile   *.* syntax on
	au CursorHold * call UpdateBuffer()
augroup END




command! -complete=customlist,NavigateNotes -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist,notes#cmd_complete NoteList call notes#list()
"command! -complete=customlist,NavigateNotes -nargs=1 NoteDelete :echo 'Removing Note: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'Removed' : 'Failed') | bdelete!
command! -complete=customlist,NavigateNotes -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! AutoSaveToggle :call AutoSaveToggle()

function notes#edit(filename)
     "echomsg fnamemodify(expand(a:filename,'/'),':h')
     let l:dir =  expand(g:notes_folder)
     let l:filename = a:filename
     if(fnamemodify(expand(a:filename,'/'),':h')=="")
	if !isdirectory(l:dir)
		exe "silent !mkdir ".l:dir
	endif
	"execute "cd ".l:dir	
	"exe "edit ".l:dir."/".l:filename
	exe "edit ".l:dir."/".l:filename
     else
	exe "edit ".l:filename
     endif	
endfunction

" When open the file, cannot set the filetype syntax..
function notes#list()
	let l:dir = expand(g:notes_folder)
	execute ":Explore ".l:dir
endfunction

function NavigateNotes(A,L,P)
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

function UpdateBuffer()
	if(g:auto_save >= 1 && &filetype=="markdown")
		let was_modified = &modified
		silent! wa
		if(was_modified && !&modified)
			echomsg "(AutoSaved at " . strftime("%H:%M:%S") . ")"
		endif
	endif
endfunction

function AutoSaveToggle()
	if g:auto_save >= 1
		let g:auto_save = 0
		echo "AutoSave is OFF"
	else
		let g:auto_save = 1
		echo "AutoSave is ON"
	endif
endfunction
