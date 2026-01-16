#import "../../config.typ": code_example, source_code_link

== Database Management System: MariaDB

The selection of the database management system (DBMS) was a critical architectural decision, given the data-intensive nature of the restaurant ordering platform and its specific requirements for geospatial processing. MariaDB was chosen as the primary relational database, serving as the persistent storage layer for all structured data, including user profiles, restaurant catalog, orders, and transactional records.

=== Justification for MariaDB
MariaDB, a community-developed fork of MySQL, was selected over competitors such as PostgreSQL and standard MySQL for several strategic reasons:

- *Native Geospatial Support*: The application relies heavily on location-based services, specifically the `MapController` which filters restaurants by proximity. MariaDB provides efficient, native implementation of spatial functions such as `ST_Distance_Sphere`. This allows for accurate calculation of distances on the Earth's surface directly within the database engine, eliminating the need for expensive application-side processing or external geospatial libraries.
- *Performance Characteristics*: MariaDB's thread pool handling and query optimizer are highly tuned for read-heavy workloads, which characterizes the majority of the application's traffic (e.g., browsing menus, viewing restaurant lists).
- *JSON Compatibility*: The support for JSON column types allows for semi-structured data storage within the relational model. This capability is utilized for flexible attributes, such as storing complex opening hours configurations or varying menu item options, without necessitating a NoSQL solution.
- *Licensing and Ecosystem*: As a fully open-source solution with a strong commitment to the GPL license, MariaDB aligns with the project's preference for open technologies. Its binary compatibility with MySQL ensures seamless integration with the Laravel framework, which treats it as a first-class citizen.

=== Comparison with Alternatives
- *PostgreSQL*: While PostgreSQL offers robust geospatial extentions via PostGIS, the complexity of configuring and maintaining PostGIS was deemed unnecessary for the project's specific scope (radius filtering and distance calculation). MariaDB's out-of-the-box spatial functions provided the required functionality with lower operational overhead.
- *NoSQL (MongoDB)*: A document store was considered for the menu catalog but rejected due to the inherently relational nature of orders, customers, and payments. Maintaining ACID compliance (data integrity) for financial transactions was prioritized over schema flexibility.
