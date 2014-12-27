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
|**:NoteDelete**&nbsp;_filename_ </code>|  Delete a note |
|**:NoteAutoSaveToggle** | Activate/Deactivate automatic save for the current _.note_ buffer |

______
Parameters
---
| Parameter | Default Value | Description |
|-----------|---------------|-------------|
|g:notes_folder| ~/.notes   | Folder containing the notes |
|g:notes_autosave| 0        | Enable/Disable the autosave of the notes |
|g:notes_autosave_time| 30  | Defines the minimum interval between 2 successive automatic saves |
______


Editing key mapping
---
|Combination | Modes   | Name function | Description |
|------------| :-----: | ------------- | ----------- |
|<leader> + i| I / N   | note-new-cbox-inline | Create a new checkbox inline |
|<leader> + o| I / N   | note-new-cbox-below  | Create a new checkbox in the line below the current one|
|<leader> + O| I / N   | note-new-cbox-above | Create a new checkbox in the line above the current one|
|<leader> + x|  N      | notes#toggle_checkbox | Toggle the state of the checkbox between done and undone ([x]/[ ])|

______

ToDo
---
- Autosave
- Proper README
- ~~Fast CheckBox~~
- Scratch notes
- Fast Export
- Synchronization

