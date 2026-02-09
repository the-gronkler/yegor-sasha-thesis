#import "../../config.typ": *

== Deployment

The deployment strategy for the system relies on containerization to ensure consistency across development and production environments. The application is hosted on a virtualized infrastructure provided by Microsoft Azure, utilizing Docker for service orchestration.

=== Infrastructure

The production environment is hosted on an Azure Virtual Machine @AzureVMDocs. The decision to utilize a self-managed VM rather than a Platform-as-a-Service (PaaS) solution was driven by cost efficacy and the need for granular control over the environment. While PaaS offerings provide automated scaling, a VM offers a predictable cost structure and allows for a custom Docker-based configuration that exactly mirrors the local development setup. Security is enforced through network security groups (NSGs) which restrict access to essential ports (HTTP/HTTPS for public access and SSH for administration).

=== Container Orchestration

The system utilizes Docker Compose to define and manage the multi-container application. While Docker provides the containerization runtime, Docker Compose adds a declarative orchestration layer: a single YAML file defines multiple interdependent services, their networking, and their shared volumes. This allows the entire stack to be started, stopped, and rebuilt with a single command.

The architecture separates concerns into distinct services - application logic, reverse proxy, and database - each running in its own isolated container. This approach represents a middle ground between two alternatives:

- *Single-container deployment* - bundles all components (web server, application, database) into one image. While simpler to deploy, this approach sacrifices isolation: a database crash can terminate the web server, updates require rebuilding everything, and resource limits cannot be set per-component.
- *Distributed deployment* - runs each service on separate physical or virtual machines. This provides maximum isolation and independent scaling but introduces network latency between components, operational complexity in managing multiple hosts, and significantly higher infrastructure costs.

The multi-container approach on a single host combines the benefits of both: services remain isolated with independent lifecycles and resource limits, yet communicate over a low-latency virtual network without the overhead of managing multiple machines.

In production systems, databases are typically hosted on dedicated managed services (e.g., Azure Database for MySQL) to ensure automated backups, replication, and independent scaling; however, for this academic project, co-locating the database within the Compose stack - with data persistence ensured via Docker volumes, as detailed in the Database Service section - provides sufficient reliability while minimizing infrastructure costs.

By encapsulating the entire technology stack in container definitions, the host VM functions as a generic execution environment, greatly reducing configuration drift between development and production. The following sections detail the individual services and their roles.

==== Application Service (`app`)
The `app` service functions as the central logic unit, purposely deviating from the standard "single process per container" paradigm to prioritize consistency and deployment simplicity. By utilizing *Supervisor* @SupervisorDocs as an internal process manager, this service packages the entire application runtime -- PHP-FPM, the Nginx web server, and asynchronous workers -- into a cohesive artifact.

Supervisor acts as the container's entry point (PID 1), responsible for spawning and monitoring the disparate components required for the application to function. Unlike a standard shell script, Supervisor provides active process control: it ensures that the Nginx web server, the PHP-FPM runtime, the Laravel queue worker, and the Reverb WebSocket server run simultaneously. Crucially, it provides a self-healing mechanism by automatically restarting any of these critical background processes if they fail or crash, ensuring high availability within the isolated environment.

*Rationale for Internal Architecture:*
- *Versioning Consistency*: Bundling the request handlers (Nginx/PHP) with the background processors (Queue Workers/Reverb) guarantees that all components operate on the exact same version of the source code. This eliminates the risk of "skew" where a separate worker container might process a job using outdated class definitions.
- *Operational Simplicity*: Using Supervisor to manage the lifecycle of the Queue and WebSocket servers alongside the web server allows the entire application to be scaled or restarted as a single atomic unit.
- *Local Asset Delivery*: Including Nginx inside the container provides the necessary capability to serve compiled frontend assets and handle FastCGI communication over a low-latency local socket, removing the need for complex shared volumes or external web server configuration.

*Build Optimization:*
The service employs a multi-stage #source_code_link("Dockerfile") to ensure efficiency. Frontend assets are compiled in a temporary Node.js stage and copied to the final PHP stage. The final stage also includes a Node.js installation to support hot module replacement during local development, as the same image serves both development and production environments (differentiated by the `APP_ENV` argument).

==== Reverse Proxy (`caddy`)
The `caddy` service acts as the dedicated ingress gateway, decoupling public access management from the application logic.

*Rationale for Separation:*
- *Automated Security*: Caddy handles the acquisition and renewal of SSL/TLS certificates (via Let's Encrypt) @CaddyDocs completely independently of the application. This ensures strict encryption standards without requiring the `app` service to manage sensitive certificate files or domain validation challenges.
- *Infrastructure Abstraction*: By serving as the single entry point, Caddy abstracts the complexity of the internal network. The application container can listen on a simple, unencrypted port, unaware of the external domain configuration, while Caddy handles the translation from secure public requests to internal traffic.

==== Database Service (`db`)
A MariaDB 10.11 instance provides the relational data storage for the application. As discussed above, co-locating the database within the Compose stack is a deliberate trade-off for this academic project. Data integrity is preserved through a Docker volume mounted to the container's data directory, ensuring that database files persist independently of the container's lifecycle. This means the database can be stopped, upgraded, or rebuilt without losing data - the volume remains on the host filesystem and is reattached when the container restarts.

=== Continuous Deployment with GitHub Actions

Deployments to the production environment are automated through a GitHub Actions workflow (#source_code_link(".github/workflows/deploy.yml")) that triggers on every push to the `master` branch. The workflow connects to the Azure VM via SSH and executes a deployment script that fetches the latest code, verifies the environment configuration, and rebuilds the Docker containers.

The pipeline follows a pull-based deployment model: rather than pushing built artifacts to the server, the workflow instructs the VM to pull changes from the repository and rebuild locally. This approach ensures that the production build process is identical to local development, reducing the risk of environment-specific issues. The workflow also supports manual dispatch with an optional commit SHA parameter, enabling rollbacks to specific versions when needed.

Key steps in the deployment process include container teardown (`docker compose down`), rebuild with cache invalidation (`--build --renew-anon-volumes`), and cleanup of unused images to conserve disk space. The entire deployment completes in under two minutes, providing rapid iteration cycles while maintaining the consistency guarantees of containerized infrastructure.
