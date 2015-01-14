Vim-Notes
===

_Yet another note plugin for VIM_

_Working in progress..._
______
Commands
---
| Command | Description |
|---|---|
|**:Note**&nbsp;_filename_      | This command creates a new Note buffer. This is saved in a new file inside the folder g:notes_folder (set to ~/.notes by default). If no extension is specified the new file will be created with '.note' and it will be processed in the editor using the _markdown_ syntax highlighting. |
|**:NoteList**             | Shows all the notes available inside the folder g:notes_folder |
|**:NoteDelete**&nbsp;_filename_|  Delete a note |
|**:NoteAutoSaveToggle** | Activate/Deactivate automatic save for the current _.note_ buffer |

______
Parameters
---
| Parameter | Default Value | Description |
|-----------|:-------------:|-------------|
|g:notes_folder| ~/.notes   | Folder containing the notes |
|g:notes_autosave| 0        | Enable/Disable the autosave of the notes |
|g:notes_autosave_time| 30  | Defines the minimum interval between 2 successive automatic saves |
|g:notes_compiler| markdown   | Defines the compiler for note files |
|g:notes_export_folder| ~/.notes/md2html   | Folder containing the exported notes |
|g:default_keymap| 1   | Load the default plugin keymap |


______


Editing key mapping
---
|Combination | Modes   | Name function | Description |
|------------| :-----: | :-----------: | ----------- |
|&lt;_leader_&gt;&nbsp;+&nbsp;[i| I / N   | note-new-cbox-inline | Create a new checkbox inline |
|&lt;_leader_&gt;&nbsp;+&nbsp;[o| I / N   | note-new-cbox-below  | Create a new checkbox in the line below the current one|
|&lt;_leader_&gt;&nbsp;+&nbsp;[O| I / N   | note-new-cbox-above | Create a new checkbox in the line above the current one|
|&lt;_leader_&gt;&nbsp;+&nbsp;[x|  N      | notes#toggle_checkbox | Toggle the state of the checkbox between done and undone ([x]/[ ])|

______


Fast Export key mapping
---
|Combination | Modes   | Name function | Description |
|------------| :-----: | :-----------: | ----------- |
|&lt;_leader_&gt;&nbsp;+&nbsp;[e| N   | notes#export | Export the current note buffer in a specified folder|


Key mapping override
---
The plugin sets by default all the described key mappings, but this can be easily disabled.
For instance, if you want your set of customized keybindings, you can just edit the vimrc as follows:

    "Disable the default key mapping
    let g:default_keymap = 0

    "Apply your own key mapping
    nmap <Leader>ni (note-new-cbox-inline)
    nmap <Leader>ni (note-new-cbox-inline)
    imap <Leader>ni (note-new-cbox-inline)
    nmap <Leader>no (note-new-cbox-below)
    imap <Leader>no (note-new-cbox-below)
    nmap <Leader>nO (note-new-cbox-above)
    imap <Leader>nO (note-new-cbox-above)
    nmap <Leader>nx :call notes#toggle_checkbox(line('.'))<cr>
    " Fast Export function
    nmap <leader>ne :call notes#export() <cr>
