# sqlitehelper

SQLite database viewer.

## Folder structure

### database

Classes, functions to represents SQLite entities in the program.


### views

Contains models & view. Model implement ChangeNotifierProvider for database entities.
Views is consumers of models. There are views for a different db entities.

The model for the view contains into same file or samle folder inside views folder like view.

