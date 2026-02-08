# Citation Findings

## Summary

- **Total unique citations found: 65**
- **Citations covering multiple facts**: FowlerPEAA2002 (Facts 18, 21, 22, 71, 72), MartinCleanArch2017 (Facts 23, 81), MartinAgile2002 (Facts 23, 81), MariaDBDocs (Facts 9, 10, 11, 12, 13, 14, 80), LaravelDocs (Facts 29, 35, 74, 89), ReactDocs (Facts 42, 76, 88), GDPR2016 (Fact 5), WCAG21 (Facts 7, 86), ViteDocs (Facts 45, 46, 87), InertiaJSDocs (Facts 30, 36, 37, 39), CloudflareR2Docs (Facts 25, 26, 28), MapboxDocs (Facts 52, 53, 54), PHPDocs (Facts 20, 32, 33), TypstDocs (Facts 63, 64), GrandViewOnlineFood2024 (Facts 1, 2, 3, 4)

---

## Citations

### Citation 1: Fowler - Patterns of Enterprise Application Architecture

- **BibTeX Key**: `FowlerPEAA2002`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{FowlerPEAA2002,
  author = {Martin Fowler},
  title = {Patterns of Enterprise Application Architecture},
  publisher = {Addison-Wesley Professional},
  year = {2002},
  isbn = {978-0321127426}
}
```

- **Covers Facts**: 18, 21, 22, 71, 72
- **Relevance**: Defines the Active Record pattern, Data Mapper pattern, and Repository pattern. The thesis extensively references these patterns when discussing Eloquent ORM architecture and comparing it with enterprise alternatives. Also covers the Association Class / Rich Association pattern.

---

### Citation 2: Martin - Clean Architecture

- **BibTeX Key**: `MartinCleanArch2017`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{MartinCleanArch2017,
  author = {Robert C. Martin},
  title = {Clean Architecture: A Craftsman's Guide to Software Structure and Design},
  publisher = {Pearson},
  year = {2017},
  isbn = {978-0134494166}
}
```

- **Covers Facts**: 23, 81
- **Relevance**: Defines the SOLID principles (Single Responsibility Principle, Open-Closed Principle) referenced in the thesis when discussing ORM limitations and broadcasting architecture.

---

### Citation 3: Martin - Agile Software Development

- **BibTeX Key**: `MartinAgile2002`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{MartinAgile2002,
  author = {Robert C. Martin},
  title = {Agile Software Development, Principles, Patterns, and Practices},
  publisher = {Prentice Hall},
  year = {2002},
  isbn = {978-0135974445}
}
```

- **Covers Facts**: 23, 81
- **Relevance**: Original source for the SOLID principles. Alternative citation to MartinCleanArch2017 -- use whichever is more appropriate; this is the original source where SOLID was first systematically described.

---

### Citation 4: Evans - Domain-Driven Design

- **BibTeX Key**: `EvansDDD2003`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{EvansDDD2003,
  author = {Eric Evans},
  title = {Domain-Driven Design: Tackling Complexity in the Heart of Software},
  publisher = {Addison-Wesley Professional},
  year = {2003},
  isbn = {978-0321125217}
}
```

- **Covers Facts**: 78
- **Relevance**: Defines the Domain Service pattern referenced in the map architecture chapter.

---

### Citation 5: Frost - Atomic Design

- **BibTeX Key**: `FrostAtomicDesign2016`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{FrostAtomicDesign2016,
  author = {Brad Frost},
  title = {Atomic Design},
  publisher = {Brad Frost},
  year = {2016},
  isbn = {978-0998296609},
  url = {https://atomicdesign.bradfrost.com/}
}
```

- **Covers Facts**: 75
- **Relevance**: Defines the atomic design methodology referenced in the frontend architecture chapter for component hierarchy.

---

### Citation 6: Wroblewski - Mobile First

- **BibTeX Key**: `WroblewskiMobileFirst2011`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{WroblewskiMobileFirst2011,
  author = {Luke Wroblewski},
  title = {Mobile First},
  publisher = {A Book Apart},
  year = {2011},
  isbn = {978-1937557027}
}
```

- **Covers Facts**: 77
- **Relevance**: Defines the mobile-first design approach referenced in the frontend architecture chapter.

---

### Citation 7: GDPR EU Regulation

- **BibTeX Key**: `GDPR2016`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{GDPR2016,
  author = {{European Parliament and Council of the European Union}},
  title = {Regulation (EU) 2016/679 on the Protection of Natural Persons with Regard to the Processing of Personal Data (General Data Protection Regulation)},
  year = {2016},
  url = {https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 5
- **Relevance**: The actual GDPR regulation referenced in the context chapter under regulatory factors. Published in Official Journal of the European Union L 119, 4.5.2016, pp. 1-88.
- **Verified URL**: https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng

---

### Citation 8: WCAG 2.1 W3C Recommendation

- **BibTeX Key**: `WCAG21`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{WCAG21,
  author = {{World Wide Web Consortium}},
  title = {Web Content Accessibility Guidelines (WCAG) 2.1},
  year = {2018},
  url = {https://www.w3.org/TR/WCAG21/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 7, 86
- **Relevance**: The WCAG 2.1 standard referenced in non-functional requirements and frontend accessibility implementation. Published as a W3C Recommendation on 5 June 2018.
- **Verified URL**: https://www.w3.org/TR/WCAG21/

---

### Citation 9: NIST FIPS 197 - AES

- **BibTeX Key**: `NISTFIPS197`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{NISTFIPS197,
  author = {{National Institute of Standards and Technology}},
  title = {FIPS 197: Advanced Encryption Standard (AES)},
  year = {2001},
  url = {https://csrc.nist.gov/pubs/fips/197/final},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 6
- **Relevance**: The AES-256 encryption standard referenced in the non-functional requirements for security. Originally published November 26, 2001, updated May 9, 2023 with no technical changes.
- **Verified URL**: https://csrc.nist.gov/pubs/fips/197/final

---

### Citation 10: Haerder & Reuter - ACID Properties

- **BibTeX Key**: `HaerderReuter1983`
- **Type**: article
- **Full BibTeX Entry**:

```bibtex
@article{HaerderReuter1983,
  author = {Theo H{\"a}rder and Andreas Reuter},
  title = {Principles of Transaction-Oriented Database Recovery},
  journal = {ACM Computing Surveys},
  volume = {15},
  number = {4},
  pages = {287--317},
  year = {1983},
  doi = {10.1145/289.291}
}
```

- **Covers Facts**: 17
- **Relevance**: Coined the ACID acronym (Atomicity, Consistency, Isolation, Durability) referenced when discussing MariaDB's transaction properties for financial data.

---

### Citation 11: MariaDB Foundation - About

- **BibTeX Key**: `MariaDBAbout`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBAbout,
  author = {{MariaDB Foundation}},
  title = {About MariaDB Server},
  year = {2024},
  url = {https://mariadb.org/about/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 9, 13
- **Relevance**: Official source confirming MariaDB as a community-developed fork of MySQL and its GPL licensing. States: "MariaDB Server remains Free and Open Source Software licensed under GPLv2."
- **Verified URL**: https://mariadb.org/about/

---

### Citation 12: MariaDB - ST_Distance_Sphere Documentation

- **BibTeX Key**: `MariaDBSpatialDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBSpatialDocs,
  author = {{MariaDB Corporation}},
  title = {ST\_DISTANCE\_SPHERE},
  year = {2024},
  url = {https://mariadb.com/docs/server/reference/sql-statements/geometry-constructors/geometry-relations/st_distance_sphere},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 10, 51
- **Relevance**: Official documentation for MariaDB's ST_Distance_Sphere spatial function, which computes geodesic distance on a spherical Earth model.
- **Verified URL**: https://mariadb.com/docs/server/reference/sql-statements/geometry-constructors/geometry-relations/st_distance_sphere

---

### Citation 13: MariaDB - Thread Pool Documentation

- **BibTeX Key**: `MariaDBThreadPool`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBThreadPool,
  author = {{MariaDB Corporation}},
  title = {Thread Pool in MariaDB},
  year = {2024},
  url = {https://mariadb.com/kb/en/thread-pool-in-mariadb/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 11
- **Relevance**: Documents MariaDB's dynamic and adaptive thread pool, noting it is available in all MariaDB versions (unlike MySQL where it is enterprise-only). States thread pools are most efficient for OLTP workloads.
- **Verified URL**: https://mariadb.com/kb/en/thread-pool-in-mariadb/

---

### Citation 14: MariaDB - Galera Cluster Documentation

- **BibTeX Key**: `MariaDBGaleraCluster`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBGaleraCluster,
  author = {{MariaDB Corporation}},
  title = {MariaDB Galera Cluster},
  year = {2024},
  url = {https://mariadb.com/kb/en/replication-cluster-multi-master/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 12
- **Relevance**: Documents MariaDB's multi-master replication via Galera Cluster with synchronous replication.
- **Verified URL**: https://mariadb.com/kb/en/replication-cluster-multi-master/

---

### Citation 15: MariaDB - MySQL Compatibility

- **BibTeX Key**: `MariaDBMySQLCompat`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBMySQLCompat,
  author = {{MariaDB Corporation}},
  title = {MariaDB versus MySQL -- Compatibility},
  year = {2024},
  url = {https://mariadb.com/docs/release-notes/compatibility-and-differences/mariadb-vs-mysql-compatibility},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 14
- **Relevance**: Documents binary compatibility between MariaDB and MySQL, including protocol and client API compatibility.
- **Verified URL**: https://mariadb.com/docs/release-notes/compatibility-and-differences/mariadb-vs-mysql-compatibility

---

### Citation 16: MySQL - Licensing

- **BibTeX Key**: `MySQLLicensing`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MySQLLicensing,
  author = {{Oracle Corporation}},
  title = {MySQL: Commercial License for OEMs, ISVs and VARs},
  year = {2024},
  url = {https://www.mysql.com/about/legal/licensing/oem/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 15
- **Relevance**: Documents Oracle's dual-licensing model for MySQL (GPL + commercial), supporting the claim about MySQL's corporate ownership and dual-licensing.
- **Verified URL**: https://www.mysql.com/about/legal/licensing/oem/

---

### Citation 17: PostGIS Documentation

- **BibTeX Key**: `PostGISDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{PostGISDocs,
  author = {{PostGIS Development Team}},
  title = {PostGIS Documentation},
  year = {2024},
  url = {https://postgis.net/docs/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 16
- **Relevance**: Official PostGIS documentation confirming its advanced geospatial capabilities including geometry/geography types, spatial indexes, and OGC compliance.
- **Verified URL**: https://postgis.net/docs/

---

### Citation 18: MariaDB - Index Merge Optimization

- **BibTeX Key**: `MariaDBIndexMerge`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MariaDBIndexMerge,
  author = {{MariaDB Corporation}},
  title = {Optimizing Queries},
  year = {2024},
  url = {https://mariadb.com/kb/en/query-optimizations/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 80
- **Relevance**: Documents MariaDB's query optimizer including index merge optimization for combining separate indexes.
- **Verified URL**: https://mariadb.com/kb/en/query-optimizations/

---

### Citation 19: Laravel Documentation

- **BibTeX Key**: `LaravelDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LaravelDocs,
  author = {{Laravel LLC}},
  title = {Laravel 11.x Documentation},
  year = {2024},
  url = {https://laravel.com/docs/11.x},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 29, 35
- **Relevance**: Official Laravel documentation covering built-in features (authentication, broadcasting, queue management) and queue system drivers.
- **Verified URL**: https://laravel.com/docs/11.x

---

### Citation 20: Laravel Sanctum Documentation

- **BibTeX Key**: `LaravelSanctumDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LaravelSanctumDocs,
  author = {{Laravel LLC}},
  title = {Laravel Sanctum},
  year = {2024},
  url = {https://laravel.com/docs/11.x/sanctum},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 74
- **Relevance**: Documents Laravel Sanctum's session-based authentication for SPAs and token-based authentication for APIs.
- **Verified URL**: https://laravel.com/docs/11.x/sanctum

---

### Citation 21: Laravel Reverb Documentation

- **BibTeX Key**: `LaravelReverbDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LaravelReverbDocs,
  author = {{Laravel LLC}},
  title = {Laravel Reverb},
  year = {2024},
  url = {https://laravel.com/docs/11.x/reverb},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 48, 49
- **Relevance**: Documents Laravel Reverb as a real-time WebSocket server utilizing the Pusher protocol for broadcasting.
- **Verified URL**: https://laravel.com/docs/11.x/reverb

---

### Citation 22: Laravel Broadcasting / Echo Documentation

- **BibTeX Key**: `LaravelBroadcastingDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LaravelBroadcastingDocs,
  author = {{Laravel LLC}},
  title = {Broadcasting},
  year = {2024},
  url = {https://laravel.com/docs/11.x/broadcasting},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 50
- **Relevance**: Documents Laravel Echo as the JavaScript client library for subscribing to channels and listening for events broadcast by the server.
- **Verified URL**: https://laravel.com/docs/11.x/broadcasting

---

### Citation 23: Laravel Cashier Documentation

- **BibTeX Key**: `LaravelCashierDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LaravelCashierDocs,
  author = {{Laravel LLC}},
  title = {Laravel Cashier (Stripe)},
  year = {2024},
  url = {https://laravel.com/docs/11.x/billing},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 89
- **Relevance**: Documents Laravel Cashier's Stripe integration for subscription billing, webhook handling, and invoice generation.
- **Verified URL**: https://laravel.com/docs/11.x/billing

---

### Citation 24: Inertia.js Documentation

- **BibTeX Key**: `InertiaJSDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{InertiaJSDocs,
  author = {Jonathan Reinink},
  title = {Inertia.js -- The Modern Monolith},
  year = {2024},
  url = {https://inertiajs.com/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 30, 36, 37, 39
- **Relevance**: Official documentation for Inertia.js covering its protocol, how it eliminates the API layer, partial reloads, and its development alongside Laravel.
- **Verified URL**: https://inertiajs.com/

---

### Citation 25: Ziggy Package

- **BibTeX Key**: `ZiggyDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ZiggyDocs,
  author = {{Tighten}},
  title = {Ziggy -- Use Your Laravel Routes in JavaScript},
  year = {2024},
  url = {https://github.com/tighten/ziggy},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 38
- **Relevance**: Official repository for the Ziggy package that exposes Laravel's named routes to the JavaScript frontend.
- **Verified URL**: https://github.com/tighten/ziggy

---

### Citation 26: React Documentation - Hooks

- **BibTeX Key**: `ReactHooksDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ReactHooksDocs,
  author = {{Meta Platforms}},
  title = {Built-in React Hooks},
  year = {2024},
  url = {https://react.dev/reference/react/hooks},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 42
- **Relevance**: Official React documentation for the hooks API providing functional programming approach to state management and side effects.
- **Verified URL**: https://react.dev/reference/react/hooks

---

### Citation 27: React Documentation - Error Boundaries

- **BibTeX Key**: `ReactErrorBoundaries`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ReactErrorBoundaries,
  author = {{Meta Platforms}},
  title = {Component -- React},
  year = {2024},
  url = {https://react.dev/reference/react/Component},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 76
- **Relevance**: Documents React Error Boundaries including getDerivedStateFromError and componentDidCatch for catching rendering errors in component subtrees.
- **Verified URL**: https://react.dev/reference/react/Component

---

### Citation 28: React Native - Fast Refresh

- **BibTeX Key**: `ReactFastRefresh`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ReactFastRefresh,
  author = {{Meta Platforms}},
  title = {Fast Refresh},
  year = {2024},
  url = {https://reactnative.dev/docs/fast-refresh},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 88
- **Relevance**: Documents React Fast Refresh which preserves component state across edits. While hosted on React Native docs, Fast Refresh works the same way in web React via Vite/webpack plugins.
- **Verified URL**: https://reactnative.dev/docs/fast-refresh

---

### Citation 29: Vite Documentation

- **BibTeX Key**: `ViteDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ViteDocs,
  author = {Evan You},
  title = {Why Vite},
  year = {2024},
  url = {https://vite.dev/guide/why},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 45, 46, 87
- **Relevance**: Official documentation explaining Vite's native ES module approach, why it replaces older bundlers like Webpack, and its tree-shaking capabilities through Rollup-based production builds.
- **Verified URL**: https://vite.dev/guide/why

---

### Citation 30: Angular Documentation

- **BibTeX Key**: `AngularDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{AngularDocs,
  author = {{Google}},
  title = {Angular Documentation},
  year = {2024},
  url = {https://angular.dev/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 44
- **Relevance**: Official Angular documentation confirming TypeScript as a prerequisite; Angular is built entirely with TypeScript.
- **Verified URL**: https://angular.dev/

---

### Citation 31: Fuse.js Documentation

- **BibTeX Key**: `FuseJSDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{FuseJSDocs,
  author = {Kiro Risk},
  title = {Fuse.js -- Lightweight Fuzzy-Search Library},
  year = {2024},
  url = {https://www.fusejs.io/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 47
- **Relevance**: Official documentation for Fuse.js, a lightweight fuzzy-search library with zero dependencies used for client-side search.
- **Verified URL**: https://www.fusejs.io/

---

### Citation 32: Cloudflare R2 Documentation

- **BibTeX Key**: `CloudflareR2Docs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{CloudflareR2Docs,
  author = {{Cloudflare}},
  title = {Cloudflare R2 Documentation},
  year = {2024},
  url = {https://developers.cloudflare.com/r2/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 25, 26, 28
- **Relevance**: Official R2 documentation covering zero egress fees, S3 API compatibility, and CDN edge integration.
- **Verified URL**: https://developers.cloudflare.com/r2/

---

### Citation 33: Mapbox GL JS Documentation

- **BibTeX Key**: `MapboxGLJSDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MapboxGLJSDocs,
  author = {{Mapbox}},
  title = {Mapbox GL JS Documentation},
  year = {2024},
  url = {https://docs.mapbox.com/mapbox-gl-js/api/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 52, 53, 54
- **Relevance**: Official Mapbox documentation covering vector tile rendering performance, pricing/free tier, and comparison with raster-based alternatives.
- **Verified URL**: https://docs.mapbox.com/mapbox-gl-js/api/

---

### Citation 34: Mapbox Pricing

- **BibTeX Key**: `MapboxPricing`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{MapboxPricing,
  author = {{Mapbox}},
  title = {Mapbox Pricing},
  year = {2024},
  url = {https://www.mapbox.com/pricing},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 53
- **Relevance**: Official pricing page for Mapbox services including free tier details.
- **Verified URL**: https://www.mapbox.com/pricing

---

### Citation 35: react-map-gl Documentation

- **BibTeX Key**: `ReactMapGL`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ReactMapGL,
  author = {{vis.gl}},
  title = {react-map-gl},
  year = {2024},
  url = {https://visgl.github.io/react-map-gl/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 55
- **Relevance**: Official documentation for react-map-gl, a React wrapper for Mapbox GL JS maintained by the vis.gl project (OpenJS Foundation).
- **Verified URL**: https://visgl.github.io/react-map-gl/

---

### Citation 36: Leaflet Documentation

- **BibTeX Key**: `LeafletDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{LeafletDocs,
  author = {Volodymyr Agafonkin},
  title = {Leaflet -- An Open-Source JavaScript Library for Interactive Maps},
  year = {2024},
  url = {https://leafletjs.com/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 54
- **Relevance**: Official Leaflet documentation, relevant for comparison with Mapbox GL JS regarding raster tiles vs. vector tiles.
- **Verified URL**: https://leafletjs.com/

---

### Citation 37: Trunk-Based Development

- **BibTeX Key**: `TrunkBasedDev`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{TrunkBasedDev,
  author = {Paul Hammant},
  title = {Trunk Based Development},
  year = {2024},
  url = {https://trunkbaseddevelopment.com/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 57
- **Relevance**: The authoritative resource site for trunk-based development maintained by Paul Hammant, who has been advocating this branching strategy for over 20 years.
- **Verified URL**: https://trunkbaseddevelopment.com/

---

### Citation 38: Driessen - Git Flow

- **BibTeX Key**: `DriessenGitFlow2010`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{DriessenGitFlow2010,
  author = {Vincent Driessen},
  title = {A Successful Git Branching Model},
  year = {2010},
  url = {https://nvie.com/posts/a-successful-git-branching-model/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 58
- **Relevance**: The original blog post defining the Git Flow branching model, published January 5, 2010. The thesis contrasts trunk-based development with this approach.
- **Verified URL**: https://nvie.com/posts/a-successful-git-branching-model/

---

### Citation 39: Conventional Commits Specification

- **BibTeX Key**: `ConventionalCommits`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{ConventionalCommits,
  author = {{Conventional Commits Contributors}},
  title = {Conventional Commits 1.0.0},
  year = {2019},
  url = {https://www.conventionalcommits.org/en/v1.0.0/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 59
- **Relevance**: The official Conventional Commits 1.0.0 specification referenced in the version control chapter.
- **Verified URL**: https://www.conventionalcommits.org/en/v1.0.0/

---

### Citation 40: Twelve-Factor App

- **BibTeX Key**: `TwelveFactorApp`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{TwelveFactorApp,
  author = {Adam Wiggins},
  title = {The Twelve-Factor App},
  year = {2011},
  url = {https://12factor.net/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 27
- **Relevance**: Defines the methodology for stateless processes and horizontal scaling referenced when discussing why local filesystem storage is problematic. Factor VI (Processes) specifically addresses stateless architecture.
- **Verified URL**: https://12factor.net/

---

### Citation 41: Caddy Web Server Documentation

- **BibTeX Key**: `CaddyDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{CaddyDocs,
  author = {{Caddy Project}},
  title = {Automatic HTTPS -- Caddy Documentation},
  year = {2024},
  url = {https://caddyserver.com/docs/automatic-https},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 61
- **Relevance**: Documents Caddy's automatic HTTPS certificate acquisition and renewal via Let's Encrypt/ACME protocol.
- **Verified URL**: https://caddyserver.com/docs/automatic-https

---

### Citation 42: Supervisor Documentation

- **BibTeX Key**: `SupervisorDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{SupervisorDocs,
  author = {{Agendaless Consulting}},
  title = {Supervisor: A Process Control System},
  year = {2024},
  url = {https://supervisord.org/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 62
- **Relevance**: Official Supervisor documentation describing the client/server process control system for UNIX-like operating systems.
- **Verified URL**: https://supervisord.org/

---

### Citation 43: Typst Documentation

- **BibTeX Key**: `TypstDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{TypstDocs,
  author = {{Typst GmbH}},
  title = {Typst Documentation},
  year = {2024},
  url = {https://typst.app/docs/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 63, 64
- **Relevance**: Official Typst documentation for the modern typesetting system. Typst offers incremental compilation and was first released as open source in March 2023.
- **Verified URL**: https://typst.app/docs/

---

### Citation 44: TeX Live Guide

- **BibTeX Key**: `TeXLiveGuide`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{TeXLiveGuide,
  author = {Karl Berry},
  title = {The TeX Live Guide},
  year = {2025},
  url = {https://www.tug.org/texlive/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 65, 66
- **Relevance**: Documents TeX Live distribution including its 7+GB default installation size and complex package management, supporting the comparison with Typst.
- **Verified URL**: https://www.tug.org/texlive/

---

### Citation 45: Gentle - Docs Like Code

- **BibTeX Key**: `GentleDocsLikeCode2017`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{GentleDocsLikeCode2017,
  author = {Anne Gentle},
  title = {Docs Like Code: Collaborate and Automate to Improve Technical Documentation},
  publisher = {Lulu Press},
  year = {2017},
  isbn = {978-1387531493},
  url = {https://www.docslikecode.com/}
}
```

- **Covers Facts**: 56, 67
- **Relevance**: Defines the "Docs-as-Code" / "Everything-as-Code" methodology referenced in the development process chapters.

---

### Citation 46: PHP Enumerations Documentation

- **BibTeX Key**: `PHPEnumsDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{PHPEnumsDocs,
  author = {{The PHP Group}},
  title = {PHP Manual: Enumerations},
  year = {2024},
  url = {https://www.php.net/manual/en/language.types.enumerations.php},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 20
- **Relevance**: Official PHP documentation for backed enumerations introduced in PHP 8.1, providing type-safe representation of fixed value sets.
- **Verified URL**: https://www.php.net/manual/en/language.types.enumerations.php

---

### Citation 47: PHP 8.0 Release Announcement

- **BibTeX Key**: `PHP8Release`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{PHP8Release,
  author = {{The PHP Group}},
  title = {PHP 8.0.0 Release Announcement},
  year = {2020},
  url = {https://www.php.net/releases/8.0/en.php},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 32, 33
- **Relevance**: Official PHP 8.0 release announcement documenting modern features including named arguments, union types, attributes, constructor property promotion, and match expressions. Supports claims about PHP language maturity.
- **Verified URL**: https://www.php.net/releases/8.0/en.php

---

### Citation 48: Laracasts

- **BibTeX Key**: `Laracasts`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{Laracasts,
  author = {Jeffrey Way},
  title = {Laracasts},
  year = {2024},
  url = {https://laracasts.com/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 34
- **Relevance**: Official Laracasts website referenced as a structured video tutorial resource for Laravel.
- **Verified URL**: https://laracasts.com/

---

### Citation 49: Stack Overflow Developer Survey 2024

- **BibTeX Key**: `StackOverflowSurvey2024`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{StackOverflowSurvey2024,
  author = {{Stack Overflow}},
  title = {2024 Stack Overflow Developer Survey},
  year = {2024},
  url = {https://survey.stackoverflow.co/2024/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 40, 41
- **Relevance**: The 2024 Stack Overflow Developer Survey showing React as one of the most used web frameworks (~39.5% of developers), supporting claims about React's industry adoption.
- **Verified URL**: https://survey.stackoverflow.co/2024/

---

### Citation 50: Grand View Research - Online Food Delivery Market

- **BibTeX Key**: `GrandViewOnlineFood2024`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{GrandViewOnlineFood2024,
  author = {{Grand View Research}},
  title = {Online Food Delivery Market Size, Share \& Trends Analysis Report},
  year = {2024},
  url = {https://www.grandviewresearch.com/industry-analysis/online-food-delivery-market-report},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 1, 2, 3, 4
- **Relevance**: Market research report documenting the global online food delivery market at USD 288.84 billion in 2024 with 9.4% CAGR, supporting claims about increasing online food ordering trends and consumer expectations.
- **Verified URL**: https://www.grandviewresearch.com/industry-analysis/online-food-delivery-market-report

---

### Citation 51: QSR Digital Report 2025

- **BibTeX Key**: `QubeyondQSR2025`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{QubeyondQSR2025,
  author = {{Qu}},
  title = {2025 State of Digital Report for Fast Casual \& QSR Restaurant Brands},
  year = {2025},
  url = {https://www.qubeyond.com/2025-state-of-digital-restaurant-report/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 3, 4
- **Relevance**: Industry report documenting restaurant digitization trends, showing 57% of fast casual brands have 26%+ digital sales, supporting claims about QSR technology adoption.
- **Verified URL**: https://www.qubeyond.com/2025-state-of-digital-restaurant-report/

---

### Citation 52: Dijkstra - Separation of Concerns

- **BibTeX Key**: `DijkstraSoC1974`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{DijkstraSoC1974,
  author = {Edsger W. Dijkstra},
  title = {On the Role of Scientific Thought (EWD447)},
  year = {1974},
  url = {https://www.cs.utexas.edu/~EWD/transcriptions/EWD04xx/EWD447.html},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 82
- **Relevance**: The original manuscript where Dijkstra coined the term "separation of concerns" -- one of the foundational principles of software engineering referenced in the broadcasting implementation chapter.
- **Verified URL**: https://www.cs.utexas.edu/~EWD/transcriptions/EWD04xx/EWD447.html

---

### Citation 53: Meyer - Object-Oriented Software Construction (Open-Closed Principle)

- **BibTeX Key**: `MeyerOOSC1988`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{MeyerOOSC1988,
  author = {Bertrand Meyer},
  title = {Object-Oriented Software Construction},
  publisher = {Prentice Hall},
  year = {1988},
  isbn = {978-0136290490}
}
```

- **Covers Facts**: 81
- **Relevance**: Original source for the Open-Closed Principle ("software entities should be open for extension, but closed for modification"). Alternative to citing Robert C. Martin who popularized it as part of SOLID.

---

### Citation 54: Codd - Further Normalization (Third Normal Form)

- **BibTeX Key**: `Codd3NF1971`
- **Type**: inproceedings
- **Full BibTeX Entry**:

```bibtex
@inproceedings{Codd3NF1971,
  author = {E. F. Codd},
  title = {Further Normalization of the Data Base Relational Model},
  booktitle = {Data Base Systems: Courant Computer Science Symposia Series 6},
  publisher = {Prentice-Hall},
  year = {1971},
  pages = {33--64}
}
```

- **Covers Facts**: 68
- **Relevance**: The original paper defining Second and Third Normal Forms in relational database theory, referenced in the database design chapter.

---

### Citation 55: Bayer & McCreight - B-tree

- **BibTeX Key**: `BayerMcCreightBTree1972`
- **Type**: article
- **Full BibTeX Entry**:

```bibtex
@article{BayerMcCreightBTree1972,
  author = {Rudolf Bayer and Edward M. McCreight},
  title = {Organization and Maintenance of Large Ordered Indexes},
  journal = {Acta Informatica},
  volume = {1},
  pages = {173--189},
  year = {1972},
  doi = {10.1007/BF00288683}
}
```

- **Covers Facts**: 70
- **Relevance**: The seminal paper introducing the B-tree data structure, referenced in the database design chapter regarding efficient index-based range queries.

---

### Citation 56: W3C Pointer Events Specification

- **BibTeX Key**: `W3CPointerEvents`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{W3CPointerEvents,
  author = {{World Wide Web Consortium}},
  title = {Pointer Events},
  year = {2019},
  url = {https://www.w3.org/TR/pointerevents/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 85
- **Relevance**: W3C specification for the Pointer Events API with pointer capture, used in the map drag implementation.
- **Verified URL**: https://www.w3.org/TR/pointerevents/

---

### Citation 57: Kent C. Dodds - State Colocation

- **BibTeX Key**: `DoddsStateColocation`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{DoddsStateColocation,
  author = {Kent C. Dodds},
  title = {State Colocation Will Make Your React App Faster},
  year = {2019},
  url = {https://kentcdodds.com/blog/state-colocation-will-make-your-react-app-faster},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 79
- **Relevance**: Defines the state colocation principle ("place code as close to where it is relevant as possible") referenced in the map architecture chapter.
- **Verified URL**: https://kentcdodds.com/blog/state-colocation-will-make-your-react-app-faster

---

### Citation 58: Nielsen - Usability Engineering (Response Times)

- **BibTeX Key**: `NielsenUsability1993`
- **Type**: book
- **Full BibTeX Entry**:

```bibtex
@book{NielsenUsability1993,
  author = {Jakob Nielsen},
  title = {Usability Engineering},
  publisher = {Morgan Kaufmann},
  year = {1993},
  isbn = {978-0125184069}
}
```

- **Covers Facts**: 83, 84
- **Relevance**: Defines the three response-time limits (0.1s, 1.0s, 10s) for user interface design, foundational for understanding optimistic updates and perceived latency in interactive systems.

---

### Citation 59: Vue RFC - Composition API

- **BibTeX Key**: `VueCompositionAPIRFC`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{VueCompositionAPIRFC,
  author = {Evan You},
  title = {Composition API RFC},
  year = {2020},
  url = {https://github.com/vuejs/rfcs/blob/master/active-rfcs/0013-composition-api.md},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 43
- **Relevance**: The Vue RFC for the Composition API, which acknowledges React Hooks as a major source of inspiration. Supports the claim that Vue 3's Composition API was directly inspired by React hooks.
- **Verified URL**: https://github.com/vuejs/rfcs/blob/master/active-rfcs/0013-composition-api.md

---

### Citation 60: Jakarta Persistence Specification

- **BibTeX Key**: `JakartaPersistence`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{JakartaPersistence,
  author = {{Eclipse Foundation}},
  title = {Jakarta Persistence 3.2},
  year = {2024},
  url = {https://jakarta.ee/specifications/persistence/3.2/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 24
- **Relevance**: Official Jakarta Persistence (JPA) specification documenting the Criteria API (CriteriaBuilder, Root, Predicate) referenced when comparing Eloquent's query builder with JPA's verbose approach.
- **Verified URL**: https://jakarta.ee/specifications/persistence/3.2/

---

### Citation 61: WAI-ARIA Specification

- **BibTeX Key**: `WAIARIA`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{WAIARIA,
  author = {{World Wide Web Consortium}},
  title = {Accessible Rich Internet Applications (WAI-ARIA) 1.2},
  year = {2023},
  url = {https://www.w3.org/TR/wai-aria-1.2/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 86
- **Relevance**: W3C specification for WAI-ARIA roles and semantic markup, supporting claims about semantic HTML communicating roles to assistive technologies.
- **Verified URL**: https://www.w3.org/TR/wai-aria-1.2/

---

### Citation 62: Microsoft Azure Virtual Machines

- **BibTeX Key**: `AzureVMDocs`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{AzureVMDocs,
  author = {{Microsoft}},
  title = {Virtual Machines in Azure},
  year = {2024},
  url = {https://learn.microsoft.com/en-us/azure/virtual-machines/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 60
- **Relevance**: Official Azure documentation for virtual machines, referenced in the deployment chapter.
- **Verified URL**: https://learn.microsoft.com/en-us/azure/virtual-machines/

---

### Citation 63: Pusher Channels Protocol

- **BibTeX Key**: `PusherProtocol`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{PusherProtocol,
  author = {{Pusher}},
  title = {Pusher Channels Protocol},
  year = {2024},
  url = {https://pusher.com/docs/channels/library_auth_reference/pusher-websockets-protocol/},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 49
- **Relevance**: The Pusher WebSocket protocol specification that Laravel Reverb implements for WebSocket communication.
- **Verified URL**: https://pusher.com/docs/channels/library_auth_reference/pusher-websockets-protocol/

---

### Citation 64: AWS Well-Architected Framework - Availability

- **BibTeX Key**: `AWSAvailability`
- **Type**: online
- **Full BibTeX Entry**:

```bibtex
@online{AWSAvailability,
  author = {{Amazon Web Services}},
  title = {Availability -- Reliability Pillar},
  year = {2024},
  url = {https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/availability.html},
  urldate = {2025-01-15}
}
```

- **Covers Facts**: 8
- **Relevance**: AWS Well-Architected Framework documenting industry-standard availability targets and SLA benchmarks. Major cloud providers (AWS, Google Cloud, Azure) offer SLAs of 99.9% or higher.
- **Verified URL**: https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/availability.html

---

### Citation 65: Everest - Crow's Foot Notation

- **BibTeX Key**: `EverestCrowsFoot1976`
- **Type**: inproceedings
- **Full BibTeX Entry**:

```bibtex
@inproceedings{EverestCrowsFoot1976,
  author = {Gordon C. Everest},
  title = {Basic Data Structure Models Explained with a Common Example},
  booktitle = {Proceedings of the Fifth Texas Conference on Computing Systems},
  year = {1976},
  publisher = {IEEE}
}
```

- **Covers Facts**: 69
- **Relevance**: The original paper introducing the "inverted arrow" (crow's foot) notation for entity-relationship diagrams referenced in the database design chapter.

---

## Fact-to-Citation Mapping

| Fact | Description                                 | Citation Key(s)                          |
| ---- | ------------------------------------------- | ---------------------------------------- |
| 1    | Online food ordering market growth          | GrandViewOnlineFood2024                  |
| 2    | Consumer expectations growth                | GrandViewOnlineFood2024                  |
| 3    | Restaurant digitization trend               | GrandViewOnlineFood2024, QubeyondQSR2025 |
| 4    | Consumer online ordering expectations       | GrandViewOnlineFood2024, QubeyondQSR2025 |
| 5    | GDPR regulation                             | GDPR2016                                 |
| 6    | AES-256 encryption standard                 | NISTFIPS197                              |
| 7    | WCAG 2.1 accessibility                      | WCAG21                                   |
| 8    | 99.9% uptime SLA                            | AWSAvailability                          |
| 9    | MariaDB as MySQL fork                       | MariaDBAbout                             |
| 10   | MariaDB spatial functions                   | MariaDBSpatialDocs                       |
| 11   | MariaDB thread pool                         | MariaDBThreadPool                        |
| 12   | MariaDB multi-master replication            | MariaDBGaleraCluster                     |
| 13   | MariaDB GPL licensing                       | MariaDBAbout                             |
| 14   | MariaDB-MySQL compatibility                 | MariaDBMySQLCompat                       |
| 15   | MySQL Oracle dual licensing                 | MySQLLicensing                           |
| 16   | PostGIS capabilities                        | PostGISDocs                              |
| 17   | ACID compliance                             | HaerderReuter1983                        |
| 18   | Active Record pattern                       | FowlerPEAA2002                           |
| 19   | N+1 query problem                           | FowlerPEAA2002                           |
| 20   | PHP 8.1 enumerations                        | PHPEnumsDocs                             |
| 21   | Active Record vs Data Mapper                | FowlerPEAA2002                           |
| 22   | Data Mapper trade-offs                      | FowlerPEAA2002                           |
| 23   | Single Responsibility Principle             | MartinCleanArch2017                      |
| 24   | JPA Criteria API                            | JakartaPersistence                       |
| 25   | Cloudflare R2 zero egress fees              | CloudflareR2Docs                         |
| 26   | R2 S3 API compatibility                     | CloudflareR2Docs                         |
| 27   | Stateless architecture / horizontal scaling | TwelveFactorApp                          |
| 28   | R2 CDN edge integration                     | CloudflareR2Docs                         |
| 29   | Laravel built-in features                   | LaravelDocs                              |
| 30   | Inertia.js Laravel integration              | InertiaJSDocs                            |
| 31   | PHP deployment simplicity                   | PHP8Release                              |
| 32   | PHP pre-7.0 limitations                     | PHP8Release                              |
| 33   | PHP 8.x modern features                     | PHP8Release                              |
| 34   | Laracasts tutorials                         | Laracasts                                |
| 35   | Laravel queue system                        | LaravelDocs                              |
| 36   | SPA vs server-rendered architecture         | InertiaJSDocs                            |
| 37   | Inertia eliminates API layer                | InertiaJSDocs                            |
| 38   | Ziggy named routes                          | ZiggyDocs                                |
| 39   | Inertia partial reloads                     | InertiaJSDocs                            |
| 40   | React ecosystem size                        | StackOverflowSurvey2024                  |
| 41   | React industry adoption                     | StackOverflowSurvey2024                  |
| 42   | React hooks API                             | ReactHooksDocs                           |
| 43   | Vue Composition API inspired by hooks       | VueCompositionAPIRFC                     |
| 44   | Angular TypeScript requirement              | AngularDocs                              |
| 45   | Vite replacing Webpack                      | ViteDocs                                 |
| 46   | Vite native ES modules                      | ViteDocs                                 |
| 47   | Fuse.js fuzzy search                        | FuseJSDocs                               |
| 48   | Laravel Reverb architecture                 | LaravelReverbDocs                        |
| 49   | Pusher Protocol adherence                   | LaravelReverbDocs, PusherProtocol        |
| 50   | Laravel Echo client library                 | LaravelBroadcastingDocs                  |
| 51   | ST_Distance_Sphere accuracy                 | MariaDBSpatialDocs                       |
| 52   | Mapbox vector rendering                     | MapboxGLJSDocs                           |
| 53   | Mapbox free tier pricing                    | MapboxPricing                            |
| 54   | Leaflet raster tiles comparison             | MapboxGLJSDocs, LeafletDocs              |
| 55   | react-map-gl wrapper                        | ReactMapGL                               |
| 56   | Everything-as-Code philosophy               | GentleDocsLikeCode2017                   |
| 57   | Trunk-based development                     | TrunkBasedDev                            |
| 58   | Git Flow branching model                    | DriessenGitFlow2010                      |
| 59   | Conventional Commits spec                   | ConventionalCommits                      |
| 60   | Azure Virtual Machine hosting               | AzureVMDocs                              |
| 61   | Caddy automatic HTTPS                       | CaddyDocs                                |
| 62   | Supervisor process manager                  | SupervisorDocs                           |
| 63   | Typst typesetting system                    | TypstDocs                                |
| 64   | Typst incremental compilation               | TypstDocs                                |
| 65   | TeX Live distribution size                  | TeXLiveGuide                             |
| 66   | LaTeX multi-pass builds                     | TeXLiveGuide                             |
| 67   | Docs-as-Code philosophy                     | GentleDocsLikeCode2017                   |
| 68   | Third Normal Form                           | Codd3NF1971                              |
| 69   | Crow's foot notation                        | EverestCrowsFoot1976                     |
| 70   | B-tree indexes                              | BayerMcCreightBTree1972                  |
| 71   | Active Record pattern                       | FowlerPEAA2002                           |
| 72   | Rich Association / Association Class        | FowlerPEAA2002                           |
| 73   | Thin controller pattern                     | FowlerPEAA2002                           |
| 74   | Laravel Sanctum authentication              | LaravelSanctumDocs                       |
| 75   | Atomic design principles                    | FrostAtomicDesign2016                    |
| 76   | React Error Boundaries                      | ReactErrorBoundaries                     |
| 77   | Mobile-first responsive design              | WroblewskiMobileFirst2011                |
| 78   | Domain Service pattern (DDD)                | EvansDDD2003                             |
| 79   | State colocation principle                  | DoddsStateColocation                     |
| 80   | MariaDB index merge optimizer               | MariaDBIndexMerge                        |
| 81   | Open-Closed Principle                       | MartinCleanArch2017, MeyerOOSC1988       |
| 82   | Separation of concerns                      | DijkstraSoC1974                          |
| 83   | Optimistic UI updates                       | NielsenUsability1993                     |
| 84   | Perceived latency UX principles             | NielsenUsability1993                     |
| 85   | Pointer Events API                          | W3CPointerEvents                         |
| 86   | Semantic HTML / WAI-ARIA                    | WCAG21, WAIARIA                          |
| 87   | Tree shaking                                | ViteDocs                                 |
| 88   | React Fast Refresh                          | ReactFastRefresh                         |
| 89   | Laravel Cashier Stripe                      | LaravelCashierDocs                       |

---

## Notes for Integration

### BibTeX Compatibility with Typst

Typst can parse standard BibTeX `.bib` files. Save all entries above into a `.bib` file and reference them in Typst using:

```typst
#bibliography("references.bib")
```

### Citation Style

Use `@key` syntax in Typst body text to cite, e.g.:

```typst
The Active Record pattern @FowlerPEAA2002 maps database rows to objects.
```

### Multiple Citations per Fact

Some facts benefit from multiple citations (e.g., Fact 81 can cite both MartinCleanArch2017 and MeyerOOSC1988). Choose the most appropriate or use both.

### Market Data Citations

Facts 1-4 reference market trends. Grand View Research provides credible industry data, but the full report may require purchase. Consider citing the publicly available summary page.
