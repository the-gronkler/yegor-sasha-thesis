= Context

This project is set within the rapidly evolving food service industry, where small businesses - particularly fast food outlets - are under increasing pressure to adopt digital solutions to streamline operations and improve customer satisfaction.

While larger restaurants and chains have access to proprietary systems or can afford to partner with third-party platforms like Uber Eats for example, small businesses often lack the resources or flexibility to implement such systems.

This order tracking system is designed to address that gap by providing an affordable, customizable alternative, specifically tailored for smaller restaurants.

== Business Context

The increasing shift towards online food ordering has created new challenges for small restaurants. Customer expectations for fast and convenient service have grown, and small businesses must adapt to remain competitive. The rise of third-party services like Uber Eats, Glovo, Pyszne.pl, etc. has exacerbated these challenges by imposing high fees and limiting control over customer interactions @GrandViewOnlineFood2024. For many small restaurants, these services offer convenience and a larger customer base but at the cost of branding, direct customer relationships, and operational independence.

This project was undertaken to address these issues by providing small restaurants with a specifically tailored, scalable system that enables them to handle online orders without relying on expensive intermediaries. This project empowers restaurants to offer the same level of service expected from third-party platforms, while maintaining control over their processes and profit margins without having to commit a large amount of operational resources up-front.

== External Factors

Several external factors influence the development and operation of this system:

- *Market Trends*: The ongoing trend toward digitizing restaurant operations, particularly for quick-service restaurants (e.g., fast food or cafes), underpins the demand for systems like this one. Consumers increasingly expect online ordering, real-time tracking, and seamless payment processes @GrandViewOnlineFood2024 @QubeyondQSR2025.

- *Competition*: This is a fairly unique product, so there are few similar systems on the market. However, this does not mean that it has no competition; this system instead competes against third-party solutions in the food delivery industry. Existing third-party food delivery platforms (Uber Eats, Glovo, etc.) dominate the market, but they often impose fees and restrictions that smaller businesses find prohibitive. This project's system offers an alternative, allowing restaurants to sidestep such constraints while still meeting modern consumer expectations, although without delivery.

- *Technological Advancements*: The growing accessibility of web and mobile technologies makes it feasible for small businesses to adopt systems that previously required large-scale infrastructure. This project leverages modern web frameworks and mobile development practices to ensure the system can be deployed efficiently across a variety of devices.

- *Regulatory Factors*: Legal requirements such as data protection regulations (e.g., GDPR) @GDPR2016 influence the design of the system. This project incorporates secure data handling practices to ensure compliance, particularly regarding customer information, payment processing, and order tracking.

== Stakeholders

Key stakeholders for this project include:

=== Restaurant Owners and Managers
Small restaurant operators who seek to expand their customer base without high upfront cost, or significant disruptions to their established workflow.

==== Expectations
- A cost-effective, easy-to-integrate solution for managing orders.
- Tools to track relevant inventory and update order statuses efficiently.
- Customization options to align the system with their specific workflows.
- Analytics and reporting tools for better business insights.

=== End Users (Customers)
Customers of small restaurants, who expect a convenient, user-friendly system for placing and tracking their orders, and enjoy a seamless ordering experience. Additionally, customers who like to discover and rate restaurants based on location, popularity, and ratings.

==== Expectations
- An intuitive interface for selecting restaurants, browsing menus, placing orders, and tracking their food orders.
- Effective real-time updates on order status.
- Access to features like the restaurant heatmap to enable seamless and intuitive selection/discovery of a restaurant that best fits that user’s current needs.

== Other Systems and Integrations

Although the system is designed to function independently, it is flexible enough to integrate with existing systems and processes in small restaurants:

- *Payment Gateways*: The system is designed to support future integration with common payment gateways to handle transactions securely. The current implementation uses a mocked payment flow to validate the order lifecycle.
- *POS Systems*: The system is built in such a way as to allow for future integration with Point of Sale (POS) systems, which would enable seamless order processing from both online and in-person customers.

== Industry Standards and Regulations

Given the legal landscape surrounding online transactions and data privacy, compliance with standards such as GDPR is essential. The system is designed to ensure that sensitive customer data is handled securely, with clear consent mechanisms and robust encryption for any personal or payment-related information.

The system is designed to ensure compliance by offloading transactions to reputable third-party gateways in future iterations.
