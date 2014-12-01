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
"   echomsg 'notes: You need at least Vim 7.2'
"   finish
"endif

if !exists('g:notes_folder')
    let g:notes_folder = "~/.notes"
endif

if !exists("g:notes_autosave")
    let g:notes_autosave = 0
    let g:notes_autosave_time = 30 "seconds
endif

augroup bufferset
    autocmd!
    autocmd BufRead,BufNewFile *.note set filetype=markdown
    autocmd BufRead,BufNewFile *.note let b:notes_start_time=localtime()
    autocmd BufRead,BufNewFile   *.* syntax on
    "Autosave settings
    "au CursorHold,BufRead *.note call notes#update_buffer()
    "au BufWritePre *.note let b:notes_start_time=localtime()
augroup END


command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist, NoteList call notes#list()
"command! -complete=customlist,NavigateNotes -nargs=1 NoteDelete :echo 'Removing Note: '.'<f-args>'.' '.(delete(<f-args>) == 0 ? 'Removed' : 'Failed') | bdelete!
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! AutoSaveToggle :call notes#autosave_toggle()

function notes#edit(filename)
    let l:dir =  expand(g:notes_folder)
    let l:tmpfilename = a:filename

    "Check for file extention"
    let l:fileext = matchstr(l:tmpfilename, '\..*$')

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
    elseif(expand(g:notes_folder) != fnamemodify(expand(a:filename,'/'), ':h'))
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
        let note=a:1

        "Check for the working directory
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
    "echomsg "Time elapsed: ".(localtime()-b:notes_start_time) "DEBUG TIME
    let l:note_time_elapsed=localtime()-b:notes_start_time

    " check for the time elapsed, the value of the autosave variable and 
    " the current file type (through the .note extension)
    if(matchstr(expand('%.t'),'\^*.note$')!="" && g:notes_autosave >= 1 
                \&& l:note_time_elapsed>=g:notes_autosave_time)

        "Try to update the buffer if modified
        let was_modified = &modified
        silent! wa

        if(was_modified && !&modified)
            echomsg "(AutoSaved at " . strftime("%H:%M:%S") . ")"
            let b:notes_start_time=localtime()
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

