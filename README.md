Vim-Notes
===

_Yet another note plugin for VIM_

_Working in progress..._

Commands
---
|||
----|----
**:Note** _filename_ | This command create a new Note buffer. This is saved in a new file inside the folder g:notes_folder (set to ~/.notes by default). If no extension is specified the new file will be created with '.note' and it will be processed in the editor using the _markdown_ syntax highlighting.
**:NoteList** | Shows all the notes available inside the folder g:notes_folder
**:NoteDelete** _filename_ |  Delete a note



Configuration Parameters
---

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
|g:notes_folder| ~/.notes   | Folder containing the notes |
|g:notes_autosave| 0        | Enable/Disable the autosave of the notes |
|g:notes_autosave_time| 30  | Defines the minimum interval between 2 successive automatic saves |



ToDo
---
- Autosave
- Proper README
- Fast Export
- Synchronization

