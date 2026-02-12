= Glossary

==== Domain Entities

/ Back-of-House (BOH): The kitchen and administrative areas of a restaurant, invisible to customers, where food preparation and management tasks occur.
/ Front-of-House (FOH): The customer-facing areas of a restaurant, such as the dining room and ordering counter, where interaction with guests takes place.
/ Fulfilled: An order status indicating that the order has been successfully prepared, packaged, and handed over to the customer.
/ Restaurant: In the context of this thesis, any establishment selling consumable goods that require processing or preparation between the receipt of an order and its delivery to the customer.

==== Technical Stack & Architecture

/ Atomic Design: A methodology for creating design systems by breaking them down into five distinct levels: atoms, molecules, organisms, templates, and pages.
/ Broadcasting: The process of sending data over a WebSocket channel to update client interfaces in real-time without requiring a page refresh.
/ Eloquent: The Object-Relational Mapper (ORM) included with the Laravel framework, providing an active record implementation for working with the database.
/ Inertia.js: A framework that enables the construction of single-page applications (SPAs) using classic server-side routing and controllers, bridging the gap between backend frameworks and modern frontend libraries.
/ Middleware: Software components that intercept HTTP requests entering the application, performing tasks such as authentication, logging, or input sanitization before the request reaches the application logic.
/ Pest: A testing framework for PHP with a focus on simplicity and readability, used for writing unit and feature tests.
/ Repository Pattern: An architectural pattern that abstracts data access behind a collection-like interface, decoupling the application logic from the underlying data storage details. Referenced in this thesis for comparative purposes; the project uses a Service Layer pattern instead. //We should doublecheck that
/ Reverb: A first-party WebSocket server for Laravel applications, enabling real-time, bi-directional communication between the client and server.
/ Service Layer: A layer in the application architecture that encapsulates business logic and complex operations, keeping controllers thin and focused on request handling.
/ Spatial Indexing: A method of indexing data that allows for efficient querying of spatial objects, such as finding all points within a specific radius of a coordinate.
