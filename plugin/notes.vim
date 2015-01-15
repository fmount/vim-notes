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
	let g:notes_winid = "none"
endif

augroup bufferset
	autocmd!
	autocmd BufRead,BufNewFile *.note set filetype=markdown
	autocmd BufRead,BufNewFile *.note let b:notes_start_time=localtime()
	autocmd BufRead,BufNewFile	 *.* syntax on
	"Autosave settings
	autocmd CursorHold,BufRead *.note call notes#update_buffer()
	autocmd BufWritePre *.note let b:notes_start_time = localtime()
augroup END


command! -complete=customlist,notes#navigate -nargs=1 Note call notes#edit(<f-args>)
command! -complete=customlist, NoteList call notes#list()
command! -complete=customlist,notes#navigate -nargs=1 NoteDelete call notes#delete(<f-args>) | bdelete!
command! NoteAutoSaveToggle :call notes#autosave_toggle()

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
		exe "edit! " . l:dir . "/" . l:filename . l:newext
	else
		exe "edit! " . a:filename . l:newext
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


"DEBUG COMMANDS
command! -nargs=* BLIST call notes#blist_open()
"SKIP ALL NOTES FILES
command! -nargs=* NEXT call notes#navig("next",'\^*.note$')
command! -nargs=* PREVIOUS call notes#navig("previous",'\^*.note$')
"NAVIGATE YOUR NOTES :D
command! -nargs=* NNEXT call notes#navig("next",'^\(.*note$\)\@!.*$')
command! -nargs=* PPREVIOUS call notes#navig("previous",'^\(.*note$\)\@!.*$')


"ONLY FOR DEBUG ....FIX WINDOW NUMBER
augroup window_handling
	autocmd WinEnter * if winnr() == 2 | nnoremap <C-N> :NNEXT <CR> | endif
	autocmd WinEnter * if winnr() == 2 | nnoremap <C-P> :PPREVIOUS <CR> | endif
	
	autocmd WinLeave * if winnr() == 2 | nnoremap <C-N> :bnext! <CR> | endif
	autocmd WinLeave * if winnr() == 2 | nnoremap <C-P> :bprevious! <CR> | endif
augroup END


function notes#navig(...)

	if(!exists('a:1') || !exists('a:2'))
		echomsg "Error evaluating parameters"
		return 
	endif
	
	let mode = a:1
	let pattern = a:2
	
	"let curr = expand('%.p')
	let num_curr=bufnr(expand('%.p'))
	
	if(bufnr('$')<=1)
		return
	endif

	if(mode=="next")
		if(num_curr==bufnr('$'))
			"It's the end, so we can start from the first :D
			let jump = notes#checkNextbuffer(1,mode,pattern)
			execute "buffer! " . bufnr(jump)
		else
			let jump = notes#checkNextbuffer(num_curr+1,mode,pattern)
			execute "buffer! " . bufnr(jump)
		endif
	else "go previous buffers
		if(num_curr==1)
			let jump = notes#checkNextbuffer(bufnr('$'),mode,pattern)
			execute "buffer " . bufnr(jump)
		else
			let jump = notes#checkNextbuffer(num_curr-1,mode,pattern)
			execute "buffer " . bufnr(jump)
		endif
	endif
endfunction


function notes#checkNextbuffer(num,mode,pattern)
	
	echomsg "BufferList len: " . bufnr('$')
	echomsg "Evaluate num: " . a:num
	
	let l:filename = fnamemodify(expand(bufname(a:num), '/'), ':t')
	echomsg "The next buffer is " . l:filename

	" If Jump pattern is match or No Name buffer skip it and evaluate the next one..
	if(matchstr(l:filename,a:pattern)!="" || bufname(a:num) == "")
		"Select direction
		if(a:mode=="next")
			"Tail is reached => Restart from the first buffer
			if(a:num+1 > bufnr('$'))
				echomsg "Start from the first"
				return notes#checkNextbuffer(1,a:mode,a:pattern)
			else
				echomsg "Go Ahead"
				return notes#checkNextbuffer(a:num+1,a:mode,a:pattern)
			endif
		else
			"Head is reached => Restart from the last buffer
			if(a:num-1 < 0)
				"Go back from the last
				echomsg "Go back from the last"
				return notes#checkNextbuffer(bufnr('$'),a:mode,a:pattern)
			else
				echomsg "Go Back"
				return notes#checkNextbuffer(a:num-1,a:mode,a:pattern)
			endif
		
		endif
	else
		echomsg "I got it!"
		return a:num
	endif
endfunction


"Utility local functions

function s:blist_open()
	let all = range(1, bufnr('$'))
	let res = []
	for b in all
		if buflisted(b)
			call add(res, bufname(b))
		endif
	endfor
	"echo res
	return res
endfunction


function! s:GetBufferList()
	redir =>buflist
	silent! ls
	redir END
	return buflist
endfunction

"Get the first .note buffer available
function s:Get_fbuf()
	let blist = s:blist_open()
	for bufitem in blist
		if(matchstr(fnamemodify(expand(bufitem, '/'), ':t'),'\^*.note$')!="")
			echomsg "RETURN NOTE: " . bufnr(bufitem)
			return bufnr(bufitem)
		endif
	endfor
	return -1
endfunction

" Find a window by the assigned identifier
function s:FindWinID(id)
	for tabnr in range(1, tabpagenr('$'))
		for winnr in range(1, tabpagewinnr(tabnr, '$'))
			if gettabwinvar(tabnr, winnr, 'id') is a:id
				return [tabnr, winnr]
			endif
		endfor
	endfor
	return [-1, -1]
endfunction

command! -complete=customlist,notes#navigate -nargs=1 Scratch call notes#open(<f-args>,<f-args>)
command! -complete=customlist,notes#navigate -nargs=0 ScratchOpen call notes#open(-1,-1)
command! -bang -nargs=0 ScratchClose call notes#close(0)

function! s:open_window(position,note)

	let scr_bufnum = bufnr(a:note)
	let curr_buf = bufname('%')
	
	"Select the notes window by id
	let [tabnr, winnr]=s:FindWinID('note')
	let g:notes_winnr = winnr
	
	"Check if the note exist in the main window
	if(scr_bufnum == -1 || bufnr('$') == 1)
		"Use the existing buffer if it is a [No Name] one
		call notes#edit(a:note)
		let scr_bufnum = bufnr(a:note)

		if(g:notes_winnr == -1)
			"open a new window and move to it
			"execute a:position . s:resolve_height(g:notes_win_height) . 'new ' . a:note
			let scr_bufnum = bufnr(a:note)
			"execute a:position . s:resolve_height(g:notes_win_height) . 'split +buffer' . scr_bufnum
			execute 'sbuffer' . scr_bufnum . ' | buffer ' . curr_buf . ' | wincmd w' 
			"set an id to the new window
			let w:id = "note"
		else
			"execute 'buffer ' . curr_buf
			"Window exist, so i can simple move to it
			let [tabnr, winnr]=s:FindWinID('note')
			execute 'buffer ' . curr_buf . ' | ' . winnr . ' wincmd w | buffer ' . scr_bufnum
		endif
	else
		"Note exist: Open it in a new window if necessary
		call notes#edit(a:note)
		if(g:notes_winnr == -1)
			"execute a:position . s:resolve_height(g:notes_win_height) . 'split +buffer' . scr_bufnum
			execute 'sbuffer' . scr_bufnum . ' | buffer ' . curr_buf . ' | wincmd w'
			"set an id to the new window
			let w:id = "note"
		else
			let [tabnr, winnr]=s:FindWinID('note')
			execute 'buffer ' . curr_buf . ' | ' . winnr . ' wincmd w | buffer ' . scr_bufnum
		endif
	endif
endfunction

function! s:close_window(force)
	" close scratch window if it is the last window open, or if force
	if a:force
		let prev_bufnr = bufnr('#')
		close
		execute bufwinnr(prev_bufnr) . 'wincmd w'
	elseif winbufnr(2) ==# -1
		if tabpagenr('$') ==# 1
			bdelete
			quit
		else
			close
		endif
	endif
endfunction

function! s:resolve_height(height)
	if has('float') && type(a:height) ==# 5 " type number for float
		let abs_height = a:height * winheight(0)
		return float2nr(abs_height)
	else
		return a:height
	endif
endfunction


" Public Window handling functions

function notes#open(reset,note)
	
	" sanity check and open a note buffer in a new window
	
	if bufname('%') ==# '[Command Line]'
		echoerr 'Unable to open a note buffer from command line window.'
		return
	endif
	
	if bufnr('$') == 1 && a:note == -1
		echomsg 'No notes to open in a new window'
		return
	endif
	
	let position = g:notes_win_top ? 'topleft ' : 'botright '
	
	if(a:note == -1)
		echomsg "There is no .note file to open, so we open a simple window"
		let bst = s:Get_fbuf()
		if(bst != -1)
			"echomsg "Open the bst"
			call s:open_window(position,bufname(bst))
		else
			"echomsg "Open the last buffer"
			call s:open_window(position,bufname(bufnr('$')))
		endif
		return
	endif
	
	if(matchstr(a:note,'\^*.note$') != "")
		call s:open_window(position,a:note)
		if a:reset
			silent execute '%d _'
		else
			silent execute 'normal! G$'
		endif
	else
		echomsg "Provide a .note file type!"
	endif
endfunction

function notes#close(reset)
	
	"Select the notes window by id
	let [tabnr, winnr]=s:FindWinID('note')
	let g:notes_winnr = winnr
	
	if(g:notes_winnr == -1)
		echomsg "No window opened"
		return
	else
		echomsg "Closing window " . g:notes_winnr
		execute 'close ' . g:notes_winnr
		let g:notes_winnr = -1
	endif
endfunction
