# Thesis Project: System Features Documentation

## Introduction

This document serves as a comprehensive log of the features developed for the application. It is intended to track the technical implementation, design decisions, and functionality of the system as it evolves. This record will be used as a primary reference for writing the implementation and system design chapters of the thesis.

## Implemented Features

### Reusable Fuzzy Search Component

**Description:**
A robust, reusable client-side search functionality that allows users to filter lists of data efficiently. It leverages fuzzy matching to handle typos and partial matches, improving the user experience when looking for specific items.

**Technical Implementation:**

- **Core Logic:** Implemented as a custom React hook (`useSearch`) wrapping the `fuse.js` library.
- **Performance:** Uses `useMemo` to cache the Fuse instance and search results, preventing unnecessary re-computations on re-renders.
- **Flexibility:** Supports dynamic search keys, weighted priorities (e.g., matching a name is more important than a description), and nested object properties (e.g., searching for a restaurant by the name of a menu item it serves).
- **UI Component:** A reusable `SearchInput` component provides a consistent search interface across the application.

**Usage:**

1.  **Restaurant Discovery:** Users can search for restaurants on the main index page. The search query checks:
    - Restaurant Name (High priority)
    - Description
    - Food Types (e.g., "Italian", "Sushi")
    - Menu Item Names (Low priority)
2.  **Menu Filtering:** Inside a restaurant's detail page, users can filter the menu. The search query checks:
    - Menu Item Name (High priority)
    - Description
    - Category Name (e.g., "Starters")

**Code Reference:**

- Hook: `resources/js/Hooks/useSearch.ts`
- Component: `resources/js/Components/UI/SearchInput.tsx`
