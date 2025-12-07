# Developer Documentation

## Intro

This file stores technical documentation useful during development. If a PR introduces something that needs to be 'kept in mind' during development, it should also update this file

## Console commands

Custom artisan commands, to use type:

```powershell
php artisan <command-name>
```

- `mfs`

  Alias for: `migrate:fresh --path=database/migrations/* --seed`. Wipes the DB, reruns all migrations in the specified folder and its subfolders, and then seeds the database.

## Formatting

We use **Prettier** for code formatting. The configuration is located in [`.prettierrc`](../.prettierrc).

To format all files in the project, run:

```powershell
npm run format
```
