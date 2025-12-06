# Developer Documentation

## Intro

This file stores technical documentation useful during development. If a PR introduces something that needs to be 'kept in mind' during development, it should also update this file

## Console commands

Custom artisan commands, to use type:
```powershell
php artisan <command-name>
```

  - ```mfs```
  
    Alias for: `migrate:fresh --path=database/migrations/* --seed`. Wipes the DB, reruns all migrations in the specified folder and its subfolders, and then seeds the database.

## Internationalization (i18n)

The project supports English (`en`) and Polish (`pl`).

### Adding Translations
1.  Add keys to `lang/en.json` and `lang/pl.json`.
2.  Keys should be consistent across files.

### Using in Frontend
Use the `useTranslation` hook:
```jsx
import useTranslation from '@/Hooks/useTranslation';

const { t } = useTranslation();

return <div>{t('KeyName')}</div>;
```



  