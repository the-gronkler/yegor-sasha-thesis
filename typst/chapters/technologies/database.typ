#import "../../config.typ": code_example, source_code_link

== Database Management System: MariaDB

The selection of the database management system (DBMS) was a critical architectural decision, given the data-intensive nature of the restaurant ordering platform and its specific requirements for geospatial processing. MariaDB was chosen as the primary relational database, serving as the persistent storage layer for all structured data, including user profiles, restaurant catalog, orders, and transactional records.

=== Justification for MariaDB
MariaDB, a community-developed fork of MySQL @MariaDBAbout, was selected over competitors such as PostgreSQL and standard MySQL for several strategic reasons:

==== Native Geospatial Support

The application relies heavily on location-based services, including filtering establishments within a user-defined radius and calculating accurate distances on the Earth's surface. MariaDB provides native spatial functions (such as `ST_Distance_Sphere`) that execute these calculations directly within the database engine, eliminating the need for application-side processing @MariaDBSpatialDocs. The detailed comparison of geospatial computation approaches - including alternatives such as PostGIS and application-level Haversine - is presented in @map-tech-geospatial.

==== Performance Characteristics

MariaDB's thread pool handling and query optimizer are highly tuned for read-heavy workloads @MariaDBThreadPool, which characterizes the majority of the application's traffic (e.g., browsing menus, viewing restaurant lists). This ensures efficient handling of concurrent read operations without performance degradation.

==== JSON Compatibility

The support for JSON column types allows for semi-structured data storage within the relational model. While not currently utilized in the schema, this capability provides flexibility for future enhancements, such as storing complex opening hours configurations or varying menu item options, without necessitating a NoSQL solution.

==== Multi-Master Replication

MariaDB supports multi-master replication @MariaDBGaleraCluster, enabling data synchronization across multiple database servers. Unlike traditional master-slave replication, which restricts writes to a single master server, multi-master allows writes on multiple nodes for greater flexibility in distributed environments.

This feature facilitates future scaling by allowing geographic distribution of databases, which aligns with the application's geospatial nature where users _primarily_ access local restaurant data. Such distribution reduces latency for regional queries and maintains data consistency across the system.

==== Licensing and Ecosystem

As a fully open-source solution with a strong commitment to the GPL license @MariaDBAbout, MariaDB aligns with the project's preference for open technologies. Its binary compatibility with MySQL @MariaDBMySQLCompat ensures seamless integration with the Laravel framework, which treats it as a first-class citizen @LaravelDocs.

==== Limitations

While MariaDB excels in the areas outlined above, it has some limitations. As a fork of MySQL, it may lag behind in adopting the latest features from the broader MySQL ecosystem.

MariaDB-specific deployment and hosting options are more limited than MySQL. However, its binary compatibility with MySQL means it can typically be hosted on MySQL-compatible environments and use MySQL drivers.


Its community and ecosystem are smaller than MySQL's, potentially affecting long-term support and third-party integrations.

For highly specialized geospatial analyses beyond basic filtering and distance calculations, extensions like PostGIS in PostgreSQL offer more advanced capabilities @PostGISDocs.

=== Comparison with Alternatives

*PostgreSQL*: While PostgreSQL offers robust geospatial extensions via PostGIS, the complexity of configuring and maintaining PostGIS was deemed unnecessary for the project's specific scope (radius filtering and distance calculation). MariaDB's out-of-the-box spatial functions provided the required functionality with lower operational overhead.

*MySQL*: Although the foundation for MariaDB, MySQL is governed by Oracle. MariaDB was chosen primarily because it is a fully open-source project, whereas MySQL is not considered purely open-source due to its corporate ownership and dual-licensing model @MySQLLicensing.

*Microsoft SQL Server*: A robust enterprise solution, but its proprietary licensing model and cost barriers made it unsuitable for this project. Additionally, while compatible with PHP, the driver support and community resources for Laravel are less extensive than those for the MySQL/MariaDB ecosystem.

*NoSQL (MongoDB)*: A document store was considered for the menu catalog but rejected due to the inherently relational nature of orders, customers, and payments. Maintaining ACID compliance @HaerderReuter1983 (data integrity) for financial transactions was prioritized over schema flexibility.
