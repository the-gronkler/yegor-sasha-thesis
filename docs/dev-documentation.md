# Developer Documention

## Intro

This file stores technical documentation useful during development. if a PR intorduces something that needs to be 'kept in mind' during development, it should also update this file

## Console commands

Custom artisan commands, to use type:
```powershell
php artisan <command-name>
```

  - ```mfs```
  
    Alias for: `migrate:fresh --path=database/migrations/* --seed`. Wipes the DB, reruns all migrations in the specified folder and its subfolders, and then seeds the database.



  