# Developer Documentation

## Intro

This file stores technical documentation useful during development. If a PR introduces something that needs to be 'kept in mind' during development, it should also update this file

## Related Documents

- [Frontend Project Structure](./fe-project-structure.md)
- [TypeScript Guidelines](./ts-guidelines.md)
- [CSS Documentation](./css-documentation.md)

## Console commands

Custom artisan commands, to use type:

```powershell
php artisan <command-name>
```

- `mfs`

  Alias for: `migrate:fresh --path=database/migrations/* --seed`. Wipes the DB, reruns all migrations in the specified folder and its subfolders, and then seeds the database.

- `ziggy:generate`

  Generates the `resources/js/ziggy.js` file. Run this whenever you add or modify named routes in `routes/web.php` to make them available in the frontend.

## Formatting

### Git Hooks (Automation)

We use **Husky** and **lint-staged** to automatically format files before they are committed.

- When you run `git commit`, only the **staged files** (the ones you added) will be formatted.
- If formatting changes are made, they are automatically added to the commit.
- This ensures that no unformatted code enters the repository.

- Theat means you dont need to run the commands below manually

### Frontend (JS/TS/CSS)

We use **Prettier** for code formatting. The configuration is located in [`.prettierrc`](../.prettierrc).

To format all frontend files, run:

```powershell
npm run format
```

### Backend (PHP)

We use **Laravel Pint** for PHP formatting. The configuration is located in [`pint.json`](../pint.json).

To format all PHP files, run:

```powershell
composer run format
```

Or the alias:

```powershell
npm run format:php
```

### Format Everything

To format both frontend and backend files in one go, run:

```powershell
npm run format:all
```
