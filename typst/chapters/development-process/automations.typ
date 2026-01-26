#import "../../config.typ": *

== Automations


// === Deployment Workflow

// The deployment process follows a standard GitOps-based workflow executed via Secure Shell (SSH) access to the host machine. The procedure ensures that the live environment runs the latest verified version of the codebase.

// #code_example[
//   The typical deployment sequence involves pulling the latest changes from the version control system, rebuilding the application images to include new dependencies or frontend assets, and restarting the container orchestration services.

//   ```bash
//   # 1. Update codebase
//   git pull origin master

//   # 2. Rebuild and restart services
//   docker compose up -d --build

//   # 3. Apply database migrations
//   docker compose exec app php artisan migrate --force
//   ```
// ]

husky formatting
deployment github action
