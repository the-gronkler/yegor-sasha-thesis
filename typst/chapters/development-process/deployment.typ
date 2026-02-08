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
The `app` service uses *Supervisor* @SupervisorDocs to manage PHP-FPM, Nginx, queue workers, and the Reverb WebSocket server within a single container. This ensures versioning consistency (all components use the same code version), operational simplicity (atomic scaling/restart), and local asset delivery via Nginx. The #source_code_link("Dockerfile") uses multi-stage builds to compile frontend assets separately, keeping the production image lean.

==== Reverse Proxy (`caddy`)
The `caddy` service acts as the ingress gateway, handling SSL/TLS certificate management via Let's Encrypt @CaddyDocs independently of the application. This separates public access from application logic and allows the app container to use simple unencrypted internal ports.

==== Database Service (`db`)
A MariaDB 10.11 instance provides relational storage, co-located within Docker Compose for this academic project. Data persists via a Docker volume mounted to the container's data directory, surviving container stops, upgrades, or rebuilds.


