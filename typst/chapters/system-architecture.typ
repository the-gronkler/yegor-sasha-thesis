= System Architecture

This chapter describes the high-level design and structure of the restaurant ordering system. The focus is on architectural patterns, component interactions, data flow, and design decisions that shape how the system is organized. Unlike the Implementation chapter (which details code structure and execution), this chapter explains the conceptual architecture—how major components fit together, how data flows through the system, and what architectural principles guide the design.

== Employee Customer Divide

The system implements a clear architectural separation between customer-facing and employee-facing modules, reflecting different user journeys, authorization requirements, and interaction patterns. This separation is enforced at the routing level, controller organization, and UI layout structure.

#include "system-architecture/map-architecture.typ"

