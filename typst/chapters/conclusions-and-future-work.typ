= Conclusions and Future Work

== Conclusions

This thesis presented the design, implementation, and deployment of an order tracking and online ordering system tailored for small and medium-sized restaurants. The project addressed a concrete gap in the market: smaller food service establishments frequently lack affordable, independent digital solutions for managing online orders and engaging customers, leaving them reliant on costly third-party platforms that erode profit margins and limit operational control.

The resulting system delivers a functional, full-stack web application that enables customers to discover restaurants via an interactive map, browse menus, place orders, and receive real-time status updates, while simultaneously providing restaurant staff with tools for order management, menu configuration, and employee administration.

=== Fulfillment of Objectives

The objectives established at the outset of this project were addressed as follows.

==== Customer Experience Enhancement

An intuitive, mobile-first interface was developed, enabling customers to browse menus, place orders, and track their food in real time. The map-based restaurant discovery feature allows users to locate establishments based on proximity, quality, and popularity, complemented by a toggleable heatmap layer that visualizes restaurant density and quality across the map. Customer review functionality was implemented, permitting users to rate and comment on restaurants, with aggregate ratings influencing search results. Instant client-side search provides responsive filtering across restaurant and menu data.

==== Restaurant Operations Optimization

The employee-facing interface provides order management capabilities with real-time notifications, enabling staff to accept, track, and fulfill orders efficiently. Menu management tools allow restaurant administrators to organize items into categories, flag dishes as unavailable, and upload media assets. The role-based access control system distinguishes between restaurant workers and administrators, ensuring that operational responsibilities are clearly delineated. The system was designed to require minimal staff training, with straightforward workflows that integrate into existing business processes.

==== Customization and Scalability

The system architecture was designed with modularity as a guiding principle. The layered backend (routing, controller, service, and model layers), the component-based frontend (following atomic design principles with pages, layouts, shared components, and UI atoms), and the use of abstraction layers for storage, geospatial computation, and real-time communication all support future extensibility. The Docker Compose deployment configuration enables the entire stack to be reproduced consistently across environments, and the containerized architecture provides a clear path toward horizontal scaling.

==== Cost Reduction

A deliberate technology selection strategy prioritized self-hosted and zero-cost solutions throughout the stack. Real-time communication leverages self-hosted WebSocket infrastructure rather than subscription-based services. Media storage uses object storage with zero egress fees and a generous free tier. The database system is fully open-source. The self-managed cloud deployment, while requiring more operational effort than platform-as-a-service alternatives, keeps infrastructure costs minimal. Together, these choices demonstrate that a production-grade ordering system can be built and operated without significant recurring service expenditure, making the solution accessible to small businesses with limited budgets.

==== Technical Robustness

The system employs several measures to ensure reliability and security. Authentication and authorization are enforced at multiple levels, including route-group access control, resource-specific permission checks, and secure channel subscriptions for real-time communication. The database schema maintains referential integrity through normalization, while geospatial queries utilize spatial indexing for efficient location-based lookups. The event-driven architecture decouples synchronous operations from interface updates, preventing performance degradation during high-load scenarios. Media upload operations employ explicit consistency strategies to maintain data integrity.

=== Architectural and Technical Contributions

Beyond meeting the stated objectives, the project yielded several technical contributions worth noting.

The *three-phase map discovery pipeline* separates input normalization, proximity-first selection, and quality-based ranking into distinct, composable stages. This design enforces the guarantee that radius constraints remain absolute (no distant restaurant can displace a closer one due to higher ratings), while still incorporating quality signals into the final ordering. The approach is generalizable to other location-aware discovery applications.

The *split-protocol broadcasting topology* addresses the challenge of deploying WebSocket services in containerized environments. Internal application-to-Reverb traffic uses plain HTTP on localhost, while external browser connections use WSS over HTTPS with a Caddy reverse proxy handling SSL termination. This configuration enables secure real-time communication without requiring the WebSocket server itself to manage certificates.

The *Inertia.js integration* eliminates the traditional API layer between backend and frontend, creating a single source of truth for routing, validation, and authentication. Partial reloads allow the frontend to request only specific data subsets (such as updated restaurant lists after a filter change) while preserving client-side UI state, which proved particularly valuable for the map interface where camera position, selection state, and overlay visibility must survive data refreshes.

The *docs-as-code methodology* applied to the thesis itself, using Typst with Git version control, pull request reviews, and custom helper functions for source code references, demonstrated that academic documentation can benefit from the same engineering rigor applied to application development.

=== Limitations

Several limitations should be acknowledged.

Payment processing is currently mocked rather than integrated with a real payment gateway. While the checkout workflow and order lifecycle are fully implemented, transaction processing with an actual provider (such as Stripe or PayPal) remains outstanding. This was a deliberate scoping decision, as the core contribution of the system lies in the ordering and tracking workflows rather than financial transaction handling.


== Future Work

The system provides a solid foundation upon which several enhancements could be built to realize the full vision described in the functional requirements and to extend the platform beyond its current capabilities.

=== Payment Gateway Integration

Integrating a production payment provider such as Stripe represents the most critical next step for operational deployment. Laravel Cashier @LaravelCashierDocs provides a first-party abstraction for Stripe subscriptions and one-time payments, offering webhook handling, receipt generation, and SCA (Strong Customer Authentication) compliance. The existing order lifecycle (with its status-based state machine transitioning from "In Cart" through "Placed" to "Fulfilled") was designed to accommodate this integration: payment confirmation would trigger the status transition from cart to placed order, replacing the current mock implementation.

=== Gamified Engagement System

Implementing the specified points, badges, and discount coupon system would require new database entities for tracking user achievements and point balances, a rule engine for awarding points based on order activity, and integration with the checkout flow to allow point redemption. This feature has the potential to significantly increase repeat customer engagement and could be modeled after established loyalty program patterns in the food service industry.

=== Mobile Application

The current responsive web application could be enhanced for mobile users through a progressive approach. A Progressive Web App implementation would add installability and offline capabilities through service workers and a web app manifest. For app store distribution, the existing codebase could be packaged as a hybrid mobile application using Capacitor or Cordova, providing access to native device APIs (camera, biometric authentication) while maintaining a single codebase.

=== Server-Side Search and Indexing

For deployment scenarios with large restaurant catalogs, client-side Fuse.js search would need to be complemented or replaced by server-side full-text search. Solutions such as Meilisearch (which has a first-party Laravel Scout driver) or Elasticsearch would provide indexed, typo-tolerant search across the entire database with sub-millisecond response times, supporting features like autocomplete, faceted filtering, and search analytics.

=== Analytics and Reporting Dashboard

The functional requirements specify analytics tools for restaurant operators, including insights into order trends, customer preferences, and menu item performance. Implementing a reporting dashboard, potentially using a charting library such as Chart.js or Recharts on the frontend with aggregated query endpoints on the backend, would provide restaurant owners with actionable business intelligence to inform menu adjustments, staffing decisions, and promotional strategies.

=== Dynamic Pricing and Promotions

Tools for time-based pricing (happy hour discounts, off-peak promotions) and campaign management (buy-one-get-one offers, promotional push notifications) would enhance the platform's value proposition for restaurant operators. The existing menu item model and order pipeline could be extended with pricing rule entities and a promotion evaluation engine that applies applicable discounts during checkout.

=== Delivery Integration

The current system focuses on pick-up orders. Extending it to support delivery would require driver management, route optimization, delivery status tracking (extending the existing real-time broadcasting infrastructure), and delivery fee calculation based on distance. This represents a substantial feature expansion that would position the system as a more direct competitor to third-party delivery platforms.

=== POS System Integration

As noted in the context chapter, integration with existing Point of Sale systems would enable seamless processing of both online and in-person orders through a unified interface. This could be achieved through webhook-based event forwarding or direct API integration with common POS providers, allowing order data to flow bidirectionally between the web platform and the restaurant's physical terminal.

=== Horizontal Scaling and Infrastructure Hardening

While the current Docker Compose deployment is suitable for moderate traffic, production deployment at scale would benefit from container orchestration via Kubernetes or Docker Swarm, managed database services (such as Azure Database for MariaDB), Redis-based session and queue storage replacing the current database-backed implementations, and CDN distribution for static assets. The Reverb WebSocket server supports Redis-based horizontal scaling for distributing connections across multiple instances, which would be necessary to meet the non-functional requirement of supporting 10,000 concurrent users.

=== Internationalization

Adding multi-language support would broaden the platform's accessibility across different markets. The backend could leverage Laravel's built-in localization features, while the frontend would require a translation management solution (such as react-i18next) and locale-aware formatting for currencies, dates, and number representations.

== Closing Remarks

This project set out to demonstrate that small and medium-sized restaurants can gain access to modern digital ordering capabilities without dependence on costly third-party platforms. The resulting system fulfills this goal: it provides a working, deployable product built entirely on open-source and self-hosted technologies, covering the full lifecycle from restaurant discovery through order placement to real-time fulfillment tracking. While several features remain for future development, the architectural foundation, the modular codebase, and the containerized deployment pipeline ensure that the system can evolve incrementally to meet the growing needs of its operators and their customers.
