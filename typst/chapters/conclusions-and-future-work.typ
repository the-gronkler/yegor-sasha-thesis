= Conclusions and Future Work

== Conclusions

This thesis presented the design, implementation, and deployment of an order tracking and online ordering system tailored for small and medium-sized restaurants. The project addressed a concrete gap in the market: smaller food service establishments frequently lack affordable, independent digital solutions for managing online orders and engaging customers.

The resulting system delivers a functional, full-stack web application that enables customers to discover restaurants via an interactive map, browse menus, place orders, and receive real-time status updates, while simultaneously providing restaurant staff with tools for order management, menu configuration, and employee administration.

=== Fulfillment of Objectives

The objectives established at the outset of this project were addressed as follows.

==== Customer Experience Enhancement

An intuitive, mobile-first interface was developed, enabling customers to browse menus, place orders, and track their food in real time. The map-based restaurant discovery feature allows users to locate establishments based on proximity, quality, and popularity, complemented by a toggleable heatmap layer that visualizes restaurant density and quality. Customer review functionality was implemented, permitting users to rate and comment on restaurants, with aggregate ratings influencing search results.

==== Restaurant Operations Optimization

The employee-facing interface provides order management capabilities with real-time notifications, enabling staff to accept, track, and fulfill orders efficiently. Menu management tools allow restaurant administrators to organize items, flag dishes as unavailable, and upload media assets. The role-based access control system distinguishes between restaurant workers and administrators, ensuring clearly delineated operational responsibilities. The UX of the system was designed to require minimal staff training, with straightforward workflows that integrate into existing business processes.

==== Customization and Scalability

The system architecture was designed with modularity as a guiding principle. The layered backend (routing, controller, service, and model layers), the component-based frontend (following atomic design principles with pages, layouts, shared components, and UI atoms), and the use of abstraction layers for storage, geospatial computation, and real-time communication all support future extensibility. The Docker Compose deployment configuration enables the entire stack to be reproduced consistently across environments, and the containerized architecture provides a clear path toward horizontal scaling.

==== Cost Reduction

A deliberate technology selection strategy prioritized self-hosted and zero-cost solutions throughout the stack. Real-time communication leverages self-hosted WebSocket infrastructure rather than subscription-based services. Media storage uses object storage with zero egress fees and a generous free tier. The database system is fully open-source. The self-managed cloud deployment, while requiring more operational effort than platform-as-a-service alternatives, keeps infrastructure costs minimal. Together, these choices demonstrate that a production-grade ordering system can be built and operated without significant recurring service expenditure, making the solution accessible to small businesses with limited budgets.

==== Technical Robustness

Authentication and authorization are enforced at multiple levels, including route-group access control, resource-specific permission checks, and secure channel subscriptions for real-time communication. The database schema maintains referential integrity through normalization, while geospatial queries utilize spatial indexing for efficient location-based lookups. The event-driven architecture decouples synchronous operations from interface updates, preventing performance degradation during high-load scenarios. Media upload operations employ explicit consistency strategies to maintain data integrity.

=== Architectural and Technical Contributions

The *three-phase map discovery pipeline* separates input normalization, proximity-first selection, and quality-based ranking. This design enforces the guarantee that radius constraints remain absolute while incorporating quality signals.

The *split-protocol broadcasting topology* enables secure real-time communication in containerized environments by handling internal application traffic via HTTP and external connections via WSS over HTTPS.

The *Inertia.js integration* creates a single source of truth for routing and validation. Partial reloads allow the frontend to request specific data subsets while preserving client-side UI state, critical for the map interface.

The *docs-as-code methodology* applied to the thesis itself, using Typst with Git version control, pull request reviews, and custom helper functions for source code references, demonstrated that academic documentation can benefit from the same engineering rigor applied to application development.

=== Limitations

Payment processing is currently mocked rather than integrated with a real payment gateway. While the checkout workflow and order lifecycle are fully implemented, transaction processing with an actual provider (such as Stripe or PayPal) remains outstanding. This was a deliberate scoping decision, as the core contribution of the system lies in the ordering and tracking workflows rather than financial transaction handling.

== Future Work

The system currently serves its intended purpose as a robust, cost-effective solution for small and medium-sized enterprises (SMEs). The following enhancements represent opportunities to extend the platform's value proposition and scalability, rather than corrections to its core functionality.

=== Operational Integrations

*Payment Gateway Integration*: While the current mock implementation verifies the order flow, integrating a production provider such as Stripe remains a key step for automated revenue capture. This feature was excluded from the academic scope due to cost barriers and complexity unrelated to the core research goals, but the modular architecture allows for its seamless addition.

*Delivery Logistics*: The platform currently focuses on pick-up orders, aligning with the operational reality of many small local restaurants. Implementing driver management and route optimization would enable these businesses to compete directly with major delivery aggregators as they scale their operations.

*POS Synchronization*: As many target SMEs operate without complex digital infrastructure, direct Point of Sale (POS) integration was not a Day 1 requirement. Future development could add bidirectional synchronization to unify online and on-premise order streams for larger establishments with existing POS investments.

=== Customer Engagement and Analytics

*Business Intelligence Dashboard*: Providing actionable insights into sales trends and menu performance would further empower restaurant owners. This enhancement builds upon the data already captured by the system, transforming raw order logs into strategic decision-making tools. As a value-add extension rather than a core functional requirement, it leverages existing infrastructure to provide competitive advantage without modifying transactional logic.
// Yes this data is already in the system we just have to present it in a readable way - these insights will enable restaurant owners to optimize their offerings and marketing strategies based on customer behavior and preferences, acting as an additional selling point for the system. Not a core responsibility but a value-add feature that leverages the existing data infrastructure.

*Dynamic Pricing*: Introducing time-based discounts and promotional campaigns would allow restaurants to smooth demand curves. While this sophisticated capability is common in enterprise-grade platforms, it represents an optional tool for growing SMEs or more adventurous operators to actively manage demand during off-peak hours.
// A cool feature that most competitors have - not something that SME usually do at scale, but could be used as they grow, or by more adventurous operators. This would be an optional feature that could be enabled as restaurants grow and seek more advanced tools to manage demand.

=== Architectural Evolution

*Mobile Native Features*: The current responsive web application intentionally lowers adoption barriers for new customers by eliminating the need for installation. However, packaging the codebase as a hybrid mobile app using Capacitor would offer a dedicated experience for persistent, loyal users. This approach adds value through native capabilities like push notifications and background location services without requiring a rewrite of the existing component architecture.
// here the motivation is simple - currently is implemented as web app to lower up-front effort required for customer users - they just have to go to the website, no need to install anything. The web app aims to provide a a native app - like experience for mobile users. However for frequent users, and app would be way more convenient. The system is already built with a component-based architecture that would allow for a hybrid mobile app to be developed without significant changes to the core logic, and the use of Capacitor would enable access to native features without requiring a full rewrite.

*Production Scalability*: The current Docker Compose deployment perfectly matches the traffic needs of typical SMEs. Migration to Kubernetes and managed database services remains a viable roadmap for transforming the standalone product into a multi-tenant SaaS platform capable of serving thousands of concurrent businesses.

*Internationalization*: Implementing multi-language support would lower adoption barriers for diverse communities. This expansion would allow the platform to serve non-English speaking markets without requiring changes to the underlying logic.

== Closing Remarks

This project demonstrates that small restaurants can access modern digital ordering capabilities without dependence on costly third-party platforms. The system fulfills its primary goal: providing a working, deployable product built on open-source technologies. The architectural foundation ensures that the system can evolve incrementally to meet the growing needs of its operators.
