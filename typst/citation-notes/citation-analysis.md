# Thesis Citation Analysis

## Summary

- **Total facts needing citations: 89**
- **Chapters with most needs**: Technologies/Database (9), Technologies/React-Frontend (8), Technologies/ORM (7), Technologies/Backend (7), Technologies/Map (5), Context (5), Development-Process/Thesis-Documentation (5), Technologies/Inertia (4), Non-Functional Requirements (3), Technologies/Blob-Storage (4), Technologies/Realtime (3), System-Architecture/Frontend (3), System-Architecture/Map (3), Database Design (3), Implementation/Optimistic-Updates (2), Development-Process/Version-Control (3), Development-Process/Deployment (3), Implementation/Broadcasting (2), System-Architecture/Backend (2), System-Architecture/Data-Persistence (2), Conclusions (4), Development-Process/Overview (1), Implementation/Map (1), Implementation/Frontend-Accessibility (1), Implementation/Frontend-Workflow (2)

## Chapter-by-Chapter Analysis

---

### Introduction (`typst/chapters/introduction.typ`)

No uncited factual claims identified. This chapter describes the project's own purpose and is appropriately self-referential.

---

### Context (`typst/chapters/context.typ`)

#### Fact 1

- **Statement**: "The increasing shift towards online food ordering has created new challenges for small restaurants."
- **Location**: Line 11, "Business Context" section
- **Type**: Statistical / Market trend
- **Why citation needed**: This asserts a market trend as fact. While the sentence continues with a citation `[1]` for the third-party services claim, the broader trend of increasing online food ordering itself requires supporting data.
- **Suggested search terms**: "online food ordering market growth statistics", "food delivery industry trends"

#### Fact 2

- **Statement**: "Customer expectations for fast and convenient service have grown"
- **Location**: Line 11, "Business Context" section
- **Type**: Statistical / Market trend
- **Why citation needed**: Claims about changing consumer expectations should be backed by consumer survey data or market research reports.
- **Suggested search terms**: "consumer expectations food delivery", "restaurant customer expectations digital ordering survey"

#### Fact 3

- **Statement**: "The ongoing trend toward digitizing restaurant operations, particularly for quick-service restaurants"
- **Location**: Line 19, "Market Trends" under External Factors
- **Type**: Market trend
- **Why citation needed**: Asserts an industry-wide trend as fact without supporting data.
- **Suggested search terms**: "restaurant digitization trend", "quick service restaurant technology adoption"

#### Fact 4

- **Statement**: "Consumers increasingly expect online ordering, real-time tracking, and seamless payment processes."
- **Location**: Line 19, "Market Trends" under External Factors
- **Type**: Statistical / Consumer behavior
- **Why citation needed**: Specific consumer expectations need survey or market research support.
- **Suggested search terms**: "consumer expectations online ordering real-time tracking", "food service consumer behavior survey"

#### Fact 5

- **Statement**: "Legal requirements such as data protection regulations (e.g., GDPR) influence the design of the system."
- **Location**: Line 25, "Regulatory Factors" under External Factors
- **Type**: Legal / Regulatory
- **Why citation needed**: GDPR should be cited with reference to the actual regulation or an authoritative summary.
- **Suggested search terms**: "GDPR regulation official text", "EU General Data Protection Regulation 2016/679"

---

### Aims and Objectives (`typst/chapters/aims-and-objectives.typ`)

No uncited factual claims identified. This chapter describes project goals and does not make external factual assertions.

---

### Non-Functional Requirements (`typst/chapters/non-functional-requirements.typ`)

#### Fact 6

- **Statement**: "User data, including payment details, must be encrypted using AES-256 standards."
- **Location**: Line 8, "Security" section
- **Type**: Technical mechanism / Security standard
- **Why citation needed**: AES-256 is a specific encryption standard (NIST) and should reference the standard specification.
- **Suggested search terms**: "AES-256 NIST FIPS 197", "Advanced Encryption Standard specification"

#### Fact 7

- **Statement**: "The interface must meet WCAG 2.1 accessibility standards"
- **Location**: Line 20, "Usability" section
- **Type**: Technical standard
- **Why citation needed**: WCAG 2.1 is a specific W3C standard and should be cited with a reference to the official specification.
- **Suggested search terms**: "WCAG 2.1 W3C Web Content Accessibility Guidelines", "W3C WCAG 2.1 specification"

#### Fact 8

- **Statement**: "Ensure 99.9% uptime with a reliable disaster recovery mechanism."
- **Location**: Line 16, "Availability" section
- **Type**: Best practice / Industry standard
- **Why citation needed**: The 99.9% uptime figure is an industry SLA benchmark. Citing industry standards for availability targets would strengthen this requirement.
- **Suggested search terms**: "SLA uptime standards 99.9", "cloud service availability industry benchmarks"

---

### Database Management System: MariaDB (`typst/chapters/technologies/database.typ`)

#### Fact 9

- **Statement**: "MariaDB, a community-developed fork of MySQL"
- **Location**: Line 8, "Justification for MariaDB"
- **Type**: Historical fact
- **Why citation needed**: The historical relationship between MariaDB and MySQL should be cited (MariaDB Foundation or official documentation).
- **Suggested search terms**: "MariaDB fork MySQL history", "MariaDB Foundation about"

#### Fact 10

- **Statement**: "MariaDB provides native spatial functions (such as ST_Distance_Sphere) that execute these calculations directly within the database engine"
- **Location**: Line 12, "Native Geospatial Support"
- **Type**: Technical mechanism
- **Why citation needed**: Claims about MariaDB's spatial function capabilities should reference official documentation.
- **Suggested search terms**: "MariaDB ST_Distance_Sphere documentation", "MariaDB spatial functions reference"

#### Fact 11

- **Statement**: "MariaDB's thread pool handling and query optimizer are highly tuned for read-heavy workloads"
- **Location**: Line 16, "Performance Characteristics"
- **Type**: Performance claim
- **Why citation needed**: This makes a specific performance claim about MariaDB's architecture that should be backed by documentation or benchmarks.
- **Suggested search terms**: "MariaDB thread pool performance", "MariaDB query optimizer read-heavy workloads"

#### Fact 12

- **Statement**: "MariaDB supports multi-master replication, enabling data synchronization across multiple database servers."
- **Location**: Line 24, "Multi-Master Replication"
- **Type**: Technical mechanism
- **Why citation needed**: Claims about replication capabilities should reference official MariaDB documentation.
- **Suggested search terms**: "MariaDB multi-master replication documentation", "MariaDB Galera Cluster"

#### Fact 13

- **Statement**: "As a fully open-source solution with a strong commitment to the GPL license"
- **Location**: Line 30, "Licensing and Ecosystem"
- **Type**: Factual claim / Legal
- **Why citation needed**: The licensing model of MariaDB should reference the official license documentation.
- **Suggested search terms**: "MariaDB GPL license", "MariaDB open source licensing"

#### Fact 14

- **Statement**: "Its binary compatibility with MySQL ensures seamless integration with the Laravel framework, which treats it as a first-class citizen."
- **Location**: Line 30, "Licensing and Ecosystem"
- **Type**: Technical mechanism
- **Why citation needed**: Binary compatibility claim and Laravel's first-class support should cite both MariaDB docs and Laravel docs.
- **Suggested search terms**: "MariaDB MySQL binary compatibility", "Laravel MariaDB support documentation"

#### Fact 15

- **Statement**: "MySQL is governed by Oracle. MariaDB was chosen primarily because it is a fully open-source project, whereas MySQL is not considered purely open-source due to its corporate ownership and dual-licensing model."
- **Location**: Line 47, Comparison with MySQL
- **Type**: Factual claim / Legal
- **Why citation needed**: Claims about Oracle's ownership and MySQL's dual-licensing model need citation.
- **Suggested search terms**: "MySQL Oracle ownership", "MySQL dual licensing GPL commercial"

#### Fact 16

- **Statement**: "PostGIS in PostgreSQL offer more advanced capabilities" (for specialized geospatial analyses)
- **Location**: Line 41, Limitations
- **Type**: Comparative statement
- **Why citation needed**: The claim that PostGIS offers more advanced geospatial capabilities should reference PostGIS documentation.
- **Suggested search terms**: "PostGIS capabilities documentation", "PostGIS vs MariaDB spatial comparison"

#### Fact 17

- **Statement**: "Maintaining ACID compliance (data integrity) for financial transactions was prioritized over schema flexibility."
- **Location**: Line 51, NoSQL comparison
- **Type**: Technical mechanism
- **Why citation needed**: ACID compliance as a database concept should be cited with a foundational reference.
- **Suggested search terms**: "ACID properties database transactions", "ACID compliance relational databases Codd"

---

### Object-Relational Mapping (ORM) (`typst/chapters/technologies/orm.typ`)

#### Fact 18

- **Statement**: "Eloquent implements the Active Record pattern"
- **Location**: Line 5
- **Type**: Architectural pattern
- **Why citation needed**: The Active Record pattern is a well-known design pattern that should cite its origin (Martin Fowler's Patterns of Enterprise Application Architecture).
- **Suggested search terms**: "Active Record pattern Martin Fowler", "Patterns of Enterprise Application Architecture Active Record"

#### Fact 19

- **Statement**: "preventing the N+1 query problem that commonly arises when iterating over collections with lazy-loaded relationships"
- **Location**: Line 10
- **Type**: Technical mechanism / Known problem
- **Why citation needed**: The N+1 query problem is a well-documented issue in ORM literature and should be cited.
- **Suggested search terms**: "N+1 query problem ORM", "N+1 select problem database"

#### Fact 20

- **Statement**: "PHP 8.1 introduced backed enumerations, providing type-safe representation of fixed value sets as first-class language constructs."
- **Location**: Line 20
- **Type**: Historical fact / Technical mechanism
- **Why citation needed**: The introduction of enumerations in PHP 8.1 should cite the PHP RFC or official documentation.
- **Suggested search terms**: "PHP 8.1 enumerations RFC", "PHP backed enums documentation"

#### Fact 21

- **Statement**: "the _Active Record_ pattern - against the _Data Mapper_ pattern commonly found in enterprise Java (Spring Data JPA) or .NET (Entity Framework) environments"
- **Location**: Line 29, "Architectural Context"
- **Type**: Architectural pattern
- **Why citation needed**: Both patterns are established software architecture patterns that should cite Martin Fowler or similar authoritative source.
- **Suggested search terms**: "Data Mapper pattern Martin Fowler", "Active Record vs Data Mapper patterns enterprise architecture"

#### Fact 22

- **Statement**: "While Data Mapper offers greater architectural purity and testability for large-scale enterprise systems, it incurs significant boilerplate overhead"
- **Location**: Line 31
- **Type**: Comparative statement
- **Why citation needed**: This comparative architectural claim should be supported by software engineering literature.
- **Suggested search terms**: "Active Record Data Mapper comparison enterprise", "ORM patterns comparison software engineering"

#### Fact 23

- **Statement**: "this violates the Single Responsibility Principle"
- **Location**: Line 59, Limitations
- **Type**: Architectural pattern / Principle
- **Why citation needed**: The Single Responsibility Principle (SRP) is a SOLID principle that should cite Robert C. Martin.
- **Suggested search terms**: "Single Responsibility Principle Robert Martin", "SOLID principles SRP"

#### Fact 24

- **Statement**: "In contrast, establishing similar dynamic queries in JPA often necessitates the verbose Criteria API, requiring the construction of CriteriaBuilder, Root, and Predicate objects"
- **Location**: Line 45, Comparative Analysis
- **Type**: Technical mechanism / Comparative
- **Why citation needed**: Claims about JPA Criteria API complexity should reference JPA specification or documentation.
- **Suggested search terms**: "JPA Criteria API specification", "Jakarta Persistence Criteria API"

---

### Object Storage: Cloudflare R2 (`typst/chapters/technologies/blob-storage.typ`)

#### Fact 25

- **Statement**: "Cloudflare's zero egress fees policy ensures that data can be migrated out of the platform at any time without financial cost."
- **Location**: Line 15, "Vendor Independence"
- **Type**: Factual claim / Pricing
- **Why citation needed**: The zero egress fees claim should cite Cloudflare's official pricing documentation.
- **Suggested search terms**: "Cloudflare R2 zero egress fees pricing", "Cloudflare R2 pricing documentation"

#### Fact 26

- **Statement**: "R2 provides full interface compatibility with the Amazon S3 API."
- **Location**: Line 18, "AWS S3 API Compatibility"
- **Type**: Technical mechanism
- **Why citation needed**: S3 API compatibility claim should cite Cloudflare R2 documentation.
- **Suggested search terms**: "Cloudflare R2 S3 API compatibility", "Cloudflare R2 documentation S3"

#### Fact 27

- **Statement**: "This approach builds state into the server, preventing horizontal scaling (e.g., adding a second server would result in split-brain asset availability)"
- **Location**: Line 27, Local Filesystem comparison
- **Type**: Best practice / Architecture
- **Why citation needed**: The concept of stateless servers and horizontal scaling is an established architectural principle that should be cited.
- **Suggested search terms**: "stateless server architecture horizontal scaling", "twelve-factor app stateless processes"

#### Fact 28

- **Statement**: "R2 is naturally integrated with the Cloudflare Content Delivery Network (CDN)"
- **Location**: Line 21, "Edge Integration"
- **Type**: Technical mechanism
- **Why citation needed**: CDN integration claim should reference Cloudflare documentation.
- **Suggested search terms**: "Cloudflare R2 CDN integration", "Cloudflare R2 edge caching"

---

### Backend Framework: Laravel 11 (`typst/chapters/technologies/backend-technologies.typ`)

#### Fact 29

- **Statement**: "Laravel provides out-of-the-box solutions for authentication (Sanctum), real-time broadcasting (Reverb), queue management, and email handling."
- **Location**: Line 13, "Built-in Feature Set"
- **Type**: Technical mechanism
- **Why citation needed**: Claims about Laravel's built-in features should cite official Laravel documentation.
- **Suggested search terms**: "Laravel 11 features documentation", "Laravel official documentation"

#### Fact 30

- **Statement**: "Inertia.js was originally developed alongside Laravel and offers first-class integration"
- **Location**: Line 15, "Ecosystem Alignment"
- **Type**: Historical fact
- **Why citation needed**: The development history and relationship between Inertia.js and Laravel should be cited.
- **Suggested search terms**: "Inertia.js history Laravel", "Inertia.js official documentation"

#### Fact 31

- **Statement**: "PHP applications deploy straightforwardly on commodity hosting environments. Unlike Java applications requiring JVM configuration or .NET applications needing runtime installation, PHP runs natively on most web servers with minimal setup."
- **Location**: Line 17, "Deployment Simplicity"
- **Type**: Comparative statement
- **Why citation needed**: Comparative deployment complexity claims should be supported by references.
- **Suggested search terms**: "PHP deployment simplicity comparison", "web framework deployment comparison PHP Java .NET"

#### Fact 32

- **Statement**: "This perception largely stems from earlier PHP versions (pre-7.0), which indeed lacked many features now considered standard"
- **Location**: Line 23, "PHP Language Maturity"
- **Type**: Historical fact
- **Why citation needed**: The evolution of PHP from pre-7.0 to modern versions should be cited.
- **Suggested search terms**: "PHP version history evolution", "PHP 7 performance improvements"

#### Fact 33

- **Statement**: "Modern PHP 8.x includes strict typing, attributes (annotations), named arguments, match expressions, enumerations, and readonly properties."
- **Location**: Line 25, "PHP Language Maturity"
- **Type**: Technical mechanism / Historical fact
- **Why citation needed**: Feature list of PHP 8.x should cite the PHP official documentation or release notes.
- **Suggested search terms**: "PHP 8 new features", "PHP 8.x official documentation features"

#### Fact 34

- **Statement**: "Laracasts offers structured video tutorials covering framework features and related technologies."
- **Location**: Line 31
- **Type**: Factual claim
- **Why citation needed**: Reference to an external educational resource should be cited with its URL.
- **Suggested search terms**: "Laracasts official website", "Laracasts Laravel tutorials"

#### Fact 35

- **Statement**: "Laravel's queue abstraction supports multiple backends, including database-driven queues that require no additional services."
- **Location**: Line 37, "Queue System Selection"
- **Type**: Technical mechanism
- **Why citation needed**: Queue system capabilities should cite Laravel documentation.
- **Suggested search terms**: "Laravel queue system documentation", "Laravel queue drivers database"

---

### Frontend-Backend Integration: Inertia.js (`typst/chapters/technologies/inertia.typ`)

#### Fact 36

- **Statement**: "Modern web applications typically choose between two architectural approaches: traditional server-rendered applications with full page reloads, or single-page applications (SPAs) that consume a separate API."
- **Location**: Line 5
- **Type**: Architectural pattern
- **Why citation needed**: The traditional dichotomy of web application architectures is a well-discussed concept in web development literature.
- **Suggested search terms**: "SPA vs server-rendered architecture", "web application architecture patterns"

#### Fact 37

- **Statement**: "Inertia eliminates the API layer entirely. The server renders responses that include both the page component name and its required data as JSON."
- **Location**: Line 15
- **Type**: Technical mechanism
- **Why citation needed**: Inertia's architecture should cite the official Inertia.js documentation.
- **Suggested search terms**: "Inertia.js documentation architecture", "Inertia.js how it works"

#### Fact 38

- **Statement**: "The _Ziggy_ package complements Inertia by exposing Laravel's named routes to the JavaScript frontend."
- **Location**: Line 35, "Complementary Technology: Ziggy"
- **Type**: Technical mechanism
- **Why citation needed**: Ziggy should be cited with its official repository or documentation.
- **Suggested search terms**: "Ziggy Laravel package documentation", "tightenco Ziggy GitHub"

#### Fact 39

- **Statement**: "Inertia's partial reload mechanism solves this by allowing components to request only specific props via the only option"
- **Location**: Line 29, "Partial Reloads"
- **Type**: Technical mechanism
- **Why citation needed**: This describes a specific Inertia.js feature that should cite its documentation.
- **Suggested search terms**: "Inertia.js partial reloads documentation", "Inertia.js only option"

---

### Frontend Framework: React 19 (`typst/chapters/technologies/react-frontend.typ`)

#### Fact 40

- **Statement**: "React's ecosystem significantly surpasses both Vue.js and Angular in size and diversity."
- **Location**: Line 11, "Ecosystem Maturity"
- **Type**: Comparative statement
- **Why citation needed**: Comparative ecosystem size claims require supporting evidence (npm statistics, surveys, etc.).
- **Suggested search terms**: "React Vue Angular ecosystem comparison", "npm download statistics frontend frameworks"

#### Fact 41

- **Statement**: "React remains the most widely adopted frontend framework in the industry. According to Stack Overflow's developer surveys and npm download statistics, React consistently shows higher usage than Vue.js and Angular."
- **Location**: Line 23, "Industry Adoption"
- **Type**: Statistical claim
- **Why citation needed**: Directly references surveys and statistics that must be cited with specific years and sources.
- **Suggested search terms**: "Stack Overflow developer survey frontend frameworks", "npm download statistics React Vue Angular"

#### Fact 42

- **Statement**: "React's hooks API provides a functional programming approach to state management and side effects without the complexity of class-based components."
- **Location**: Line 17, "Hooks API"
- **Type**: Technical mechanism
- **Why citation needed**: React hooks should cite official React documentation.
- **Suggested search terms**: "React hooks API official documentation", "React hooks introduction"

#### Fact 43

- **Statement**: "Vue 3's Composition API offers similar capabilities and was directly inspired by React hooks"
- **Location**: Line 17, "Hooks API"
- **Type**: Historical fact / Comparative
- **Why citation needed**: The claim that Vue's Composition API was inspired by React hooks should be cited.
- **Suggested search terms**: "Vue 3 Composition API inspiration React hooks", "Vue RFC Composition API motivation"

#### Fact 44

- **Statement**: "Angular mandates TypeScript usage"
- **Location**: Line 21, "TypeScript Integration"
- **Type**: Technical mechanism
- **Why citation needed**: Angular's TypeScript requirement should cite Angular documentation.
- **Suggested search terms**: "Angular TypeScript requirement", "Angular official documentation TypeScript"

#### Fact 45

- **Statement**: "Vite serves as the frontend build tool, replacing older bundlers like Webpack."
- **Location**: Line 37, "Build Tooling"
- **Type**: Historical fact / Technical mechanism
- **Why citation needed**: Vite as a replacement for Webpack and its architecture should cite Vite documentation.
- **Suggested search terms**: "Vite documentation official", "Vite vs Webpack comparison"

#### Fact 46

- **Statement**: "Vite serves source files directly during development using native ES modules."
- **Location**: Line 39, "Instant Development Server"
- **Type**: Technical mechanism
- **Why citation needed**: Vite's native ES module approach should cite Vite's documentation.
- **Suggested search terms**: "Vite native ES modules development server", "Vite documentation why Vite"

#### Fact 47

- **Statement**: "Fuse.js provides fuzzy search filtering for client-side datasets"
- **Location**: Line 49, "Client-Side Search with Fuse.js"
- **Type**: Technical mechanism
- **Why citation needed**: Fuse.js should be cited with its official documentation or repository.
- **Suggested search terms**: "Fuse.js documentation", "Fuse.js GitHub repository"

---

### Real-Time Communication Technologies (`typst/chapters/technologies/realtime.typ`)

#### Fact 48

- **Statement**: "Laravel Reverb ... Built on top of the Swoole asynchronous PHP runtime, it offers high-performance throughput"
- **Location**: Line 9, "Performance"
- **Type**: Technical mechanism
- **Why citation needed**: The claim that Reverb is built on Swoole should cite Laravel Reverb documentation.
- **Suggested search terms**: "Laravel Reverb documentation", "Laravel Reverb Swoole"

#### Fact 49

- **Statement**: "It adheres to the Pusher Protocol, enabling the use of robust client libraries on the frontend."
- **Location**: Line 10, "Protocol Support"
- **Type**: Technical mechanism
- **Why citation needed**: The Pusher Protocol adherence should cite either Reverb docs or Pusher Protocol specification.
- **Suggested search terms**: "Laravel Reverb Pusher Protocol", "Pusher Protocol specification"

#### Fact 50

- **Statement**: "Laravel Echo acts as the JavaScript client library, paired with Pusher.js for WebSocket connectivity."
- **Location**: Line 12
- **Type**: Technical mechanism
- **Why citation needed**: Laravel Echo and Pusher.js should cite their respective documentation.
- **Suggested search terms**: "Laravel Echo documentation", "Pusher.js documentation"

---

### Map-Based Discovery Technologies (`typst/chapters/technologies/map-technologies.typ`)

#### Fact 51

- **Statement**: "The ST_Distance_Sphere function computes geodesic distance on a spherical Earth model, providing acceptable accuracy for restaurant discovery (error < 0.5% for distances under 100 km)."
- **Location**: Line 9, "Geospatial Computation"
- **Type**: Performance claim / Technical mechanism
- **Why citation needed**: The accuracy claim of < 0.5% error requires a mathematical or documentation reference.
- **Suggested search terms**: "ST_Distance_Sphere accuracy spherical model", "geodesic distance spherical vs ellipsoidal error"

#### Fact 52

- **Statement**: "Vector-based rendering delivers smooth 60fps interactions even with hundreds of markers, outperforming raster-tile approaches"
- **Location**: Line 22, "Rendering Performance"
- **Type**: Performance claim / Comparative
- **Why citation needed**: Performance comparison between vector and raster tile rendering should cite Mapbox documentation or benchmarks.
- **Suggested search terms**: "Mapbox vector tiles performance", "vector vs raster tile rendering performance"

#### Fact 53

- **Statement**: "The free tier (50,000 map loads per month) is sufficient for development and moderate production traffic."
- **Location**: Line 26, "Cost Structure"
- **Type**: Factual claim / Pricing
- **Why citation needed**: Mapbox pricing should be cited with official pricing documentation.
- **Suggested search terms**: "Mapbox pricing free tier", "Mapbox GL JS pricing 2025"

#### Fact 54

- **Statement**: "Leaflet uses raster tiles by default (resulting in slower rendering), and vector tile support requires additional plugins."
- **Location**: Line 30
- **Type**: Technical mechanism / Comparative
- **Why citation needed**: Leaflet's rendering approach should cite Leaflet documentation.
- **Suggested search terms**: "Leaflet raster tiles documentation", "Leaflet vs Mapbox comparison"

#### Fact 55

- **Statement**: "react-map-gl wraps Mapbox GL JS with React-friendly bindings"
- **Location**: Line 34, "React Integration"
- **Type**: Technical mechanism
- **Why citation needed**: react-map-gl should be cited with its documentation or repository.
- **Suggested search terms**: "react-map-gl documentation", "react-map-gl Visgl GitHub"

---

### Development Process: Overview (`typst/chapters/development-process/overview.typ`)

#### Fact 56

- **Statement**: "The process is unified by an 'Everything-as-Code' philosophy"
- **Location**: Line 8
- **Type**: Best practice / Methodology
- **Why citation needed**: "Everything-as-Code" is an established DevOps philosophy that should be cited.
- **Suggested search terms**: "Everything as Code DevOps", "Infrastructure as Code philosophy"

---

### Development Process: Version Control (`typst/chapters/development-process/version-control.typ`)

#### Fact 57

- **Statement**: "trunk-based development model, a source-control branching strategy where developers integrate small, frequent updates directly into a shared main branch"
- **Location**: Line 9
- **Type**: Best practice / Methodology
- **Why citation needed**: Trunk-based development is a documented branching strategy that should cite authoritative sources.
- **Suggested search terms**: "trunk-based development", "trunk based development Google", "trunkbaseddevelopment.com"

#### Fact 58

- **Statement**: "Unlike long-lived feature branches common in Git Flow"
- **Location**: Line 9
- **Type**: Methodology / Historical
- **Why citation needed**: Git Flow is a specific branching model by Vincent Driessen that should be cited.
- **Suggested search terms**: "Git Flow Vincent Driessen", "successful Git branching model"

#### Fact 59

- **Statement**: "Commits follow the Conventional Commits 1.0.0 specification"
- **Location**: Line 28
- **Type**: Technical standard
- **Why citation needed**: The Conventional Commits specification should be cited with its official URL.
- **Suggested search terms**: "Conventional Commits 1.0.0 specification", "conventionalcommits.org"

---

### Development Process: Deployment (`typst/chapters/development-process/deployment.typ`)

#### Fact 60

- **Statement**: "The application is hosted on an Azure Virtual Machine."
- **Location**: Line 9
- **Type**: Factual claim
- **Why citation needed**: Microsoft Azure as a cloud platform should be cited with a reference.
- **Suggested search terms**: "Microsoft Azure virtual machines documentation", "Azure VM documentation"

#### Fact 61

- **Statement**: "Caddy handles the acquisition and renewal of SSL/TLS certificates (via Let's Encrypt) completely independently"
- **Location**: Line 43, "Reverse Proxy"
- **Type**: Technical mechanism
- **Why citation needed**: Caddy's automatic HTTPS functionality should cite Caddy documentation and Let's Encrypt.
- **Suggested search terms**: "Caddy automatic HTTPS Let's Encrypt", "Caddy web server documentation"

#### Fact 62

- **Statement**: "By utilizing Supervisor as an internal process manager ... Unlike a standard shell script, Supervisor provides active process control"
- **Location**: Line 27-29
- **Type**: Technical mechanism
- **Why citation needed**: Supervisor should be cited with its documentation.
- **Suggested search terms**: "Supervisor process manager documentation", "Supervisor Python process control"

---

### Development Process: Thesis Documentation (`typst/chapters/development-process/thesis-documentation.typ`)

#### Fact 63

- **Statement**: "The thesis is authored using _Typst_, a modern, programmable typesetting system"
- **Location**: Line 5
- **Type**: Technical mechanism
- **Why citation needed**: Typst should be cited with its official documentation or academic publication.
- **Suggested search terms**: "Typst typesetting system", "Typst official documentation"

#### Fact 64

- **Statement**: "Typst offers incremental compilation, rendering changes instantly, whereas LaTeX compilation is often slow and resource-intensive."
- **Location**: Line 23, "Performance"
- **Type**: Comparative statement
- **Why citation needed**: The performance comparison between Typst and LaTeX should cite benchmarks or documentation.
- **Suggested search terms**: "Typst vs LaTeX performance comparison", "Typst incremental compilation"

#### Fact 65

- **Statement**: "Unlike LaTeX, which typically requires multi-gigabyte distributions (e.g., TeX Live) and complex package management"
- **Location**: Line 27, "Toolchain Simplicity"
- **Type**: Comparative statement
- **Why citation needed**: TeX Live distribution size and complexity should cite TeX Live documentation.
- **Suggested search terms**: "TeX Live distribution size", "TeX Live installation requirements"

#### Fact 66

- **Statement**: "This removes the need for multi-pass builds and external bibliography processors (like Biber) required by traditional LaTeX workflows."
- **Location**: Line 28, "Bibliography Management"
- **Type**: Technical mechanism / Comparative
- **Why citation needed**: LaTeX's multi-pass bibliography workflow (Biber/BibTeX) should be cited.
- **Suggested search terms**: "LaTeX Biber bibliography processing", "LaTeX multi-pass compilation bibliography"

#### Fact 67

- **Statement**: "'Docs-as-Code' philosophy ... whereby the manuscript is treated as a software artifact"
- **Location**: Line 5
- **Type**: Methodology
- **Why citation needed**: The Docs-as-Code methodology should be cited with an authoritative reference.
- **Suggested search terms**: "Docs as Code methodology", "documentation as code software engineering"

---

### Database Design (`typst/chapters/database-design.typ`)

#### Fact 68

- **Statement**: "The schema follows the Third Normal Form to reduce redundancy and enforce integrity"
- **Location**: Line 16
- **Type**: Technical mechanism / Database theory
- **Why citation needed**: Third Normal Form (3NF) is a database normalization concept from relational database theory that should cite its foundational source.
- **Suggested search terms**: "Third Normal Form database normalization", "Codd normal forms relational database"

#### Fact 69

- **Statement**: "The Entity-Relationship Diagram uses crow's foot notation to represent cardinality and participation constraints."
- **Location**: Line 18
- **Type**: Technical mechanism / Notation
- **Why citation needed**: Crow's foot notation is a specific ERD notation standard that should be cited.
- **Suggested search terms**: "crow's foot notation ERD", "entity relationship diagram notation styles"

#### Fact 70

- **Statement**: "Usage of standard primitive types allows for the efficient execution of bounding-box queries directly through standard B-tree indices"
- **Location**: Line 66, "Spatial Data Representation"
- **Type**: Technical mechanism
- **Why citation needed**: The relationship between B-tree indexes and range queries should cite database internals literature.
- **Suggested search terms**: "B-tree index range queries database", "B-tree data structure database indexing"

---

### System Architecture: Data Persistence (`typst/chapters/system-architecture/data-persistence.typ`)

#### Fact 71

- **Statement**: "This is an example of the Active Record design pattern, which was selected over the Repository pattern"
- **Location**: Line 10
- **Type**: Architectural pattern
- **Why citation needed**: Active Record and Repository patterns should cite their original sources.
- **Suggested search terms**: "Active Record pattern Martin Fowler", "Repository pattern Domain-Driven Design"

#### Fact 72

- **Statement**: "This approach is applied to complex associations such as order line items and user preferences, which require the encapsulation of stateful data"
- **Location**: Line 52, "Handling Many-to-Many Relationships" (refers to "Rich Association")
- **Type**: Architectural pattern
- **Why citation needed**: The Rich Association / Association Class pattern is from UML/OOP literature.
- **Suggested search terms**: "association class pattern UML", "rich association object-oriented design"

---

### System Architecture: Media Storage (`typst/chapters/system-architecture/media-storage.typ`)

No additional uncited claims beyond what is covered in the blob-storage technology chapter. The chapter describes project implementation decisions.

---

### System Architecture: Backend Architecture (`typst/chapters/system-architecture/backend-architecture.typ`)

#### Fact 73

- **Statement**: "Controllers in this application follow the thin controller pattern"
- **Location**: Line 89
- **Type**: Architectural pattern / Best practice
- **Why citation needed**: The "thin controller" pattern is an established best practice in MVC architecture that should be cited.
- **Suggested search terms**: "thin controller pattern MVC", "fat model thin controller pattern"

#### Fact 74

- **Statement**: "Authentication is provided by Laravel Sanctum, which offers both session-based authentication for web requests and token-based authentication for API consumers."
- **Location**: Line 25
- **Type**: Technical mechanism
- **Why citation needed**: Laravel Sanctum's capabilities should cite Sanctum documentation.
- **Suggested search terms**: "Laravel Sanctum documentation", "Laravel Sanctum session token authentication"

---

### System Architecture: Frontend Architecture (`typst/chapters/system-architecture/frontend-architecture.typ`)

#### Fact 75

- **Statement**: "The architecture employs a three-tier component hierarchy inspired by atomic design principles."
- **Location**: Line 9
- **Type**: Architectural pattern
- **Why citation needed**: Atomic design is a specific methodology by Brad Frost that should be cited.
- **Suggested search terms**: "atomic design Brad Frost", "atomic design methodology"

#### Fact 76

- **Statement**: "React Error Boundaries catch rendering errors in component subtrees, displaying fallback UI rather than crashing the entire interface."
- **Location**: Line 45, "Error Handling"
- **Type**: Technical mechanism
- **Why citation needed**: React Error Boundaries should cite React documentation.
- **Suggested search terms**: "React Error Boundaries documentation", "React error boundary API"

#### Fact 77

- **Statement**: "The application employs mobile-first responsive design."
- **Location**: Line 41
- **Type**: Best practice / Methodology
- **Why citation needed**: Mobile-first responsive design is an established web design approach that should cite its origin (Luke Wroblewski) or W3C guidance.
- **Suggested search terms**: "mobile-first responsive design Luke Wroblewski", "mobile-first design methodology"

---

### System Architecture: Map Architecture (`typst/chapters/system-architecture/map-architecture.typ`)

#### Fact 78

- **Statement**: "This follows the Domain Service pattern from Domain-Driven Design: logic that does not naturally belong to an entity or value object is extracted into a service."
- **Location**: Line 51
- **Type**: Architectural pattern
- **Why citation needed**: Domain-Driven Design and the Domain Service pattern should cite Eric Evans' book.
- **Suggested search terms**: "Domain-Driven Design Eric Evans", "Domain Service pattern DDD"

#### Fact 79

- **Statement**: "This layered approach follows the principle of state locality: keep state as close as possible to where it is used"
- **Location**: Line 130
- **Type**: Best practice / Principle
- **Why citation needed**: The principle of state locality (or colocation) is a React community best practice that should be cited.
- **Suggested search terms**: "state colocation React", "state locality principle Kent C. Dodds"

#### Fact 80

- **Statement**: "MariaDB's query optimizer uses index merge to combine separate indexes for range queries"
- **Location**: Line 289
- **Type**: Technical mechanism
- **Why citation needed**: MariaDB's index merge optimization should cite MariaDB documentation.
- **Suggested search terms**: "MariaDB index merge optimization", "MariaDB query optimizer index merge documentation"

---

### System Architecture: Real-Time Events (`typst/chapters/system-architecture/real-time-events.typ`)

No additional uncited claims beyond those already covered in the realtime technology chapter. This chapter describes the project's own architecture.

---

### Implementation: Database (`typst/chapters/implementation/database.typ`)

No uncited factual claims. This chapter describes the project's own implementation with code examples.

---

### Implementation: Media Uploads (`typst/chapters/implementation/media-uploads.typ`)

No uncited factual claims. This chapter describes the project's own implementation.

---

### Implementation: Broadcasting (`typst/chapters/implementation/broadcasting.typ`)

#### Fact 81

- **Statement**: "It follows the open-closed principle, allowing new broadcasting behaviors to be added via event classes without modifying existing code."
- **Location**: Line 13
- **Type**: Architectural pattern / Principle
- **Why citation needed**: The Open-Closed Principle is a SOLID principle that should cite Robert C. Martin or Bertrand Meyer.
- **Suggested search terms**: "Open-Closed Principle SOLID", "Open-Closed Principle Bertrand Meyer"

#### Fact 82

- **Statement**: "It follows ... the separation of concerns principle"
- **Location**: Line 12
- **Type**: Architectural pattern / Principle
- **Why citation needed**: Separation of concerns is a fundamental software engineering principle that should cite Dijkstra or similar.
- **Suggested search terms**: "separation of concerns principle Dijkstra", "separation of concerns software engineering"

---

### Implementation: Optimistic Updates (`typst/chapters/implementation/optimistic-updates.typ`)

#### Fact 83

- **Statement**: "Optimistic updates are implemented to enhance perceived performance and user experience across the application."
- **Location**: Line 6
- **Type**: Technical mechanism / Best practice
- **Why citation needed**: Optimistic UI updates is an established UX pattern that should cite a reference.
- **Suggested search terms**: "optimistic UI updates pattern", "optimistic updates user experience"

#### Fact 84

- **Statement**: "This technique significantly enhances user experience by minimizing perceived latency in interactive systems, aligning with modern UX principles for responsive interfaces."
- **Location**: Line 18
- **Type**: Best practice / UX
- **Why citation needed**: Claims about UX principles and perceived latency should cite HCI or UX research.
- **Suggested search terms**: "perceived latency user experience", "responsive interface UX principles Nielsen"

---

### Implementation: Map Functionality (`typst/chapters/implementation/map-functionality.typ`)

#### Fact 85

- **Statement**: "The drag implementation uses ... Pointer Events API with pointer capture."
- **Location**: Line 658
- **Type**: Technical mechanism
- **Why citation needed**: The Pointer Events API is a W3C specification that should be cited.
- **Suggested search terms**: "W3C Pointer Events API specification", "Pointer Events W3C recommendation"

---

### Implementation: Frontend Accessibility (`typst/chapters/implementation/frontend-accessibility.typ`)

#### Fact 86

- **Statement**: "Components use semantic HTML elements that communicate roles to assistive technologies"
- **Location**: Line 9
- **Type**: Best practice / Standard
- **Why citation needed**: Semantic HTML and its role in accessibility should cite WCAG or WAI-ARIA specifications.
- **Suggested search terms**: "semantic HTML accessibility W3C", "WAI-ARIA semantic elements"

---

### Implementation: Frontend Workflow (`typst/chapters/implementation/frontend-workflow.typ`)

#### Fact 87

- **Statement**: "Tree shaking: Unused exports from imported modules are eliminated during bundling"
- **Location**: Line 66
- **Type**: Technical mechanism
- **Why citation needed**: Tree shaking is a specific bundling optimization technique that should cite its origin or documentation.
- **Suggested search terms**: "tree shaking JavaScript bundling", "tree shaking Rollup webpack"

#### Fact 88

- **Statement**: "React Fast Refresh, which preserves component state across edits to component bodies"
- **Location**: Line 17
- **Type**: Technical mechanism
- **Why citation needed**: React Fast Refresh should cite React or Vite documentation.
- **Suggested search terms**: "React Fast Refresh documentation", "React Fast Refresh how it works"

---

### Testing and Validation (`typst/chapters/testing-and-validation.typ`)

This chapter is empty (contains only the heading). No claims to analyze.

---

### Conclusions and Future Work (`typst/chapters/conclusions-and-future-work.typ`)

#### Fact 89

- **Statement**: "Laravel Cashier provides a first-party abstraction for Stripe subscriptions and one-time payments, offering webhook handling, receipt generation, and SCA (Strong Customer Authentication) compliance."
- **Location**: Line 58, "Payment Gateway Integration"
- **Type**: Technical mechanism
- **Why citation needed**: Laravel Cashier's capabilities should cite official documentation.
- **Suggested search terms**: "Laravel Cashier documentation", "Laravel Cashier Stripe integration"

---

## Priority Recommendations

### Highest Priority (Core Technology Claims)

These are claims that form the foundation of technology selection decisions and are most likely to be scrutinized by reviewers:

1. **MariaDB as MySQL fork and its capabilities** (Facts 9-17) -- 9 citations needed
2. **React ecosystem claims and industry statistics** (Facts 40-41) -- Must cite actual survey data
3. **Active Record / Data Mapper patterns** (Facts 18, 21-22, 71) -- Cite Martin Fowler
4. **PHP evolution claims** (Facts 32-33) -- Cite PHP documentation
5. **GDPR reference** (Fact 5) -- Cite the actual regulation
6. **WCAG 2.1 reference** (Fact 7) -- Cite the W3C specification
7. **AES-256 reference** (Fact 6) -- Cite NIST standard

### Medium Priority (Comparative and Best Practice Claims)

8. **Inertia.js and its architecture** (Facts 36-39) -- Cite documentation
9. **Vite and build tooling** (Facts 45-46) -- Cite documentation
10. **Trunk-based development and Git Flow** (Facts 57-58) -- Cite methodology sources
11. **Atomic design principles** (Fact 75) -- Cite Brad Frost
12. **Domain-Driven Design** (Fact 78) -- Cite Eric Evans
13. **SOLID principles** (Facts 23, 81, 82) -- Cite Robert C. Martin

### Lower Priority (Supporting Claims)

14. **Cloudflare R2 pricing/features** (Facts 25-28) -- Cite documentation
15. **Mapbox features and pricing** (Facts 52-53) -- Cite documentation
16. **Third-party library references** (Fuse.js, Ziggy, react-map-gl, etc.) -- Cite repositories/docs
17. **Market trend claims in Context** (Facts 1-4) -- Cite industry reports

---

## Existing Citations Summary

The thesis currently has only 6 bibliography entries:

- `SourceCodeRepo` -- The project's GitHub repository
- `GitHubCopilotRepoInstructions` -- GitHub Copilot docs (used in AI Use chapter)
- `VSCodeCopilotCustomizeChat` -- VS Code Copilot docs (used in AI Use chapter)
- `AgentsMDFormat` -- AGENTS.md specification (used in AI Use chapter)
- `BibtexDocs` -- BibTeX documentation (not used in text)
- `ListingsDocs` -- LaTeX Listings package docs (not used in text)

Plus one inline `[1]` citation in the Context chapter (source not visible in bibliography).

The thesis needs approximately **89 additional citations** to adequately support its factual claims.
