# Requirements Chapters -- Reduction Analysis

This document analyses six Typst thesis files subsection by subsection, assigning each a verdict of **KEEP**, **ABRIDGE**, **MERGE**, or **REMOVE**, with justifications and estimated line savings.

**Files analysed (total ~412 source lines):**

| #   | File                                             | Lines |
| --- | ------------------------------------------------ | ----- |
| 1   | `typst/chapters/context.typ`                     | 61    |
| 2   | `typst/chapters/functional-requirements.typ`     | 74    |
| 3   | `typst/chapters/use-case-diagram.typ`            | 63    |
| 4   | `typst/chapters/use-case-scenarios.typ`          | 157   |
| 5   | `typst/chapters/non-functional-requirements.typ` | 30    |
| 6   | `typst/chapters/aims-and-objectives.typ`         | 27    |

---

## 1. `context.typ` (61 lines)

### 1.1 Opening paragraph (lines 1-7)

**Verdict: MERGE with `aims-and-objectives.typ` / ABRIDGE (-5 lines)**

The three opening paragraphs restate the project motivation (small restaurants, third-party platform problem, affordable alternative) which is also the core content of the Aims chapter and the Business Context subsection immediately below. Collapse into a single sentence that frames the project scope and move on. The Aims chapter should hold the authoritative statement of purpose.

### 1.2 Business Context (lines 9-13)

**Verdict: MERGE with opening paragraph (-4 lines)**

Lines 11-13 repeat the same "third-party platforms charge high fees / this project addresses the gap" message already stated in lines 3-7. Fold the one truly new detail (customer expectations have grown due to online ordering trends) into the single opening paragraph proposed above. The two paragraphs here say the same thing as the opening but with slightly different words.

### 1.3 External Factors (lines 15-25)

**Verdict: ABRIDGE (-6 lines)**

Four bullet points, but the content is padded:

- **Market Trends** (line 19): First sentence restates Business Context. Cut it; keep only the consumer-expectation detail with its citations.
- **Competition** (line 21): First two sentences say "this product is unique but still competes with delivery platforms." Reduce to one sentence. The clause "although without delivery" is important but buried; make it more prominent.
- **Technological Advancements** (line 23): Generic/textbook statement ("growing accessibility of web technologies") that names no specific technology. Either remove entirely or reduce to one short sentence.
- **Regulatory Factors** (line 25): Good and specific (GDPR citation). Keep as-is.

### 1.4 Stakeholders (lines 27-47)

**Verdict: ABRIDGE (-6 lines)**

The stakeholder expectations lists duplicate functional requirements almost verbatim:

- "Tools to track relevant inventory and update order statuses efficiently" (line 36) = FR "Order Management" (FR line 55).
- "Analytics and reporting tools for better business insights" (line 38) = FR "Analytics and Reporting" (FR line 73).
- "An intuitive interface for selecting restaurants, browsing menus, placing orders, and tracking their food orders" (line 44) = FR Order Placement + Order Tracking (FR lines 6-11).
- "Engagement through rewards systems" (line 47) = FR "Gamified Rewards" (FR lines 30-32).
- "Access to features like the restaurant heatmap" (line 46) = FR "Heatmap Feature" (FR lines 19-24).

**Recommendation:** Keep the stakeholder _descriptions_ (who they are), but remove or drastically trim the "Expectations" sub-lists. Instead, add a single sentence per stakeholder cross-referencing the Functional Requirements chapter.

### 1.5 Other Systems and Integrations (lines 49-54)

**Verdict: ABRIDGE (-4 lines)**

Two bullets, one of which (POS integration) is explicitly speculative future work. Reduce to a single sentence noting the system's integration flexibility, or fold into the Scalability NFR. The Payment Gateways bullet is fine but could be one clause rather than a full bullet.

### 1.6 Industry Standards and Regulations (lines 56-60)

**Verdict: MERGE with External Factors > Regulatory Factors (-5 lines)**

Lines 58-60 repeat what line 25 already says (GDPR, secure handling of customer data, encryption). The only new detail is "offloading transactions to reputable third-party gateways" (line 60). Merge that one sentence into the Regulatory Factors bullet and delete this entire subsection.

### Context totals

| Subsection           | Verdict                          | Estimated saving |
| -------------------- | -------------------------------- | ---------------- |
| Opening paragraph    | MERGE with Aims / ABRIDGE        | 5                |
| Business Context     | MERGE with opening               | 4                |
| External Factors     | ABRIDGE                          | 6                |
| Stakeholders         | ABRIDGE (trim expectation lists) | 6                |
| Other Systems        | ABRIDGE                          | 4                |
| Industry Standards   | MERGE with External Factors      | 5                |
| **Context subtotal** |                                  | **30 lines**     |

---

## 2. `functional-requirements.typ` (74 lines)

### 2.1 Order Placement (lines 5-7)

**Verdict: KEEP**
Two clear bullet points. Core requirement, concise. No redundancy.

### 2.2 Order Tracking (lines 9-11)

**Verdict: KEEP**
Concise and necessary. Covers both online and in-person tracking.

### 2.3 Payment Integration (lines 13-14)

**Verdict: KEEP**
One bullet, essential.

### 2.4 Map Restaurant Discovery (lines 16-17)

**Verdict: KEEP**
Core differentiating feature, concise.

### 2.5 Heatmap Feature (lines 19-23)

**Verdict: KEEP**
Unique to this project and detailed enough to be useful. This is a distinguishing feature that warrants its own subsection.

### 2.6 User Account Management (lines 25-27)

**Verdict: KEEP**
Standard but necessary.

### 2.7 Gamified Rewards (lines 29-31)

**Verdict: KEEP**
Brief and project-specific.

### 2.8 Order Customization (lines 35-37)

**Verdict: KEEP**
Two bullets, concise.

### 2.9 Restaurant Ratings and Reviews (lines 39-43)

**Verdict: ABRIDGE (-2 lines)**

Lines 42-43 go into implementation detail ("average of all its review ratings whenever a review is created, updated, or deleted" and "total number of reviews displayed alongside aggregate rating"). This level of detail belongs in technical/design chapters, not in a requirements list. The same recalculation logic is repeated verbatim in `use-case-diagram.typ` (line 62). Reduce to: "The restaurant's displayed rating is the average of all review ratings and is updated automatically."

### 2.10 Order Sharing (lines 45-47)

**Verdict: REMOVE (-3 lines)**

Group order sharing and split payment are described but there is no corresponding use case scenario, no UCD element, and no evidence this is implemented. If not implemented, remove from functional requirements or explicitly move to a Future Work section. Keeping unimplemented requirements in the FR chapter invites evaluator criticism.

### 2.11 Registration -- Restaurant (line 52)

**Verdict: KEEP**
One line, necessary.

### 2.12 Order Management -- Restaurant (lines 54-56)

**Verdict: KEEP**
Core requirement, concise.

### 2.13 Customization Options -- Restaurant (lines 58-61)

**Verdict: ABRIDGE (-2 lines)**

Line 61 ("When uploading pictures, restaurant administrators have an option to select one of the pictures already uploaded for this restaurant, either for a menu item or the restaurant profile") is UI-level implementation detail, not a functional requirement. Remove or compress into the previous bullet.

### 2.14 Real-Time Updates -- Restaurant (lines 63-64)

**Verdict: KEEP**
One line, essential.

### 2.15 Dynamic Pricing and Promotions (lines 68-70)

**Verdict: REMOVE or flag as out-of-scope (-3 lines)**

Like Order Sharing, there is no use case scenario or UCD element for dynamic pricing. If not implemented, remove from the FR chapter or relegate to Future Work. Unmatched requirements weaken the thesis.

### 2.16 Analytics and Reporting (lines 72-73)

**Verdict: ABRIDGE (-1 line)**

Single vague line ("Provide insights into order trends, customer preferences, and inventory performance"). Either add one concrete sentence about what is actually implemented, or remove if not implemented.

### Functional Requirements totals

| Subsection            | Verdict | Estimated saving |
| --------------------- | ------- | ---------------- |
| Ratings and Reviews   | ABRIDGE | 2                |
| Order Sharing         | REMOVE  | 3                |
| Customization Options | ABRIDGE | 2                |
| Dynamic Pricing       | REMOVE  | 3                |
| Analytics             | ABRIDGE | 1                |
| Everything else       | KEEP    | 0                |
| **FR subtotal**       |         | **11 lines**     |

---

## 3. `use-case-diagram.typ` (63 lines)

### 3.1 Introduction paragraph (lines 1-10)

**Verdict: ABRIDGE (-2 lines)**

Lines 3-5 are boilerplate ("provides a high-level view ... serves as a bridge between requirements and technical design"). The figure caption already communicates this. Reduce the intro to one sentence introducing the three figures.

### 3.2 Actors and Roles (lines 12-21)

**Verdict: ABRIDGE (-3 lines)**

The actor descriptions are useful, but "Payment System" (line 20) and "System Actions" (line 21) are effectively described again in section 3.5 System Actions (lines 59-63). Also, the actor list partially overlaps with the Stakeholders section in `context.typ`. Keep actor definitions here (canonical location for UML actors) but trim Payment System and System Actions entries to one clause each.

### 3.3 Customer-Centric Functionality (lines 23-41)

**Verdict: ABRIDGE (-8 lines)**

This prose restates what the Functional Requirements already list and what the Use Case Scenarios describe in detail:

- "Account Creation and User Methods" (lines 33-34) = FR "User Account Management" (FR lines 25-28).
- "Map Discovery" (lines 36-37) = FR "Map Restaurant Discovery" + "Heatmap Feature" (FR lines 16-24).
- "Order Management / Cart / Checkout" (lines 39-42) = FR "Order Placement" + "Payment Integration" (FR lines 5-14) and UC2 scenario.

**Recommendation:** Replace these prose paragraphs with a brief one-sentence summary per functional module (referencing FR and UC chapters). The diagrams themselves convey the relationships visually; the prose currently re-narrates what is already shown.

### 3.4 Restaurant Management Functionality (lines 44-57)

**Verdict: ABRIDGE (-5 lines)**

Same pattern as 3.3:

- "Worker Duties" (lines 54-55) = FR "Order Management" (FR lines 54-57) and UC3 scenario.
- "Restaurant Admin Management" (lines 57-58) = FR "Customization Options" (FR lines 58-62).

Replace with brief one-liner per module with forward references.

### 3.5 System Actions (lines 59-62)

**Verdict: MERGE with FR Ratings and Reviews (-3 lines)**

The "Rating Updates" bullet (lines 62-63) repeats the exact detail from FR "Restaurant Ratings and Reviews" (FR lines 42-43) almost verbatim ("recalculated ... average of all associated review ratings"). Keep one authoritative description in the FR chapter and reference it here with a single sentence.

**Recommendation:** Also merge "Order Notifications" detail with FR "Real-Time Updates" by cross-reference.

### Use Case Diagram totals

| Subsection            | Verdict | Estimated saving |
| --------------------- | ------- | ---------------- |
| Introduction          | ABRIDGE | 2                |
| Actors and Roles      | ABRIDGE | 3                |
| Customer-Centric      | ABRIDGE | 8                |
| Restaurant Management | ABRIDGE | 5                |
| System Actions        | MERGE   | 3                |
| **UCD subtotal**      |         | **21 lines**     |

---

## 4. `use-case-scenarios.typ` (157 lines)

This is the largest file in this group and the primary target for reduction.

### 4.1 Introduction (lines 1-6)

**Verdict: KEEP**
Two sentences setting context. Fine.

### 4.2 UC1: Finding a Restaurant -- prose before figure (lines 8-20)

**Verdict: ABRIDGE (-8 lines)**

Lines 10-20 narrate every flow (main, two alternatives, search bar, list view) _before_ the structured scenario table that follows. This is redundant -- the scenario table (lines 22-54) already presents the same information in a structured format. The prose essentially previews the table contents.

**Recommendation:** Replace lines 10-20 with a 2-sentence summary: state the purpose and note that alternative flows cover geolocation denial and list-based browsing. Let the structured table speak for itself.

### 4.3 UC1: Finding a Restaurant -- scenario table (lines 22-54)

**Verdict: ABRIDGE (-4 lines)**

The alternative flow section (lines 39-49) lists sub-sub-alternatives (lines 46-49: "3a2a1", "3a2a2", "3a2a3" for the radius slider panel). This level of nested UI step detail (open panel, change slider, continue) is implementation-specific and unnecessarily granular for a use case scenario.

**Recommendation:** Remove the nested "Browsing restaurants using map filters" sub-alternative (lines 46-49) or compress to a single mention: "Optionally, the customer adjusts the search radius via the filter panel."

### 4.4 UC2: Creating an Order -- prose before figure (lines 57-72)

**Verdict: ABRIDGE (-8 lines)**

Same issue as UC1: lines 59-72 narrate the main flow and all four alternative flows in prose, duplicating the structured table that follows (lines 74-115). Additional issues:

- Line 65 ("we do not show in the table for simplicity") is meta-commentary that should be removed.
- Line 63 has a typo: "details (mocked for this implementation). and" -- period before "and".

**Recommendation:** Replace lines 59-72 with a 2-3 sentence summary. The table contains all the detail.

### 4.5 UC2: Creating an Order -- scenario table (lines 74-115)

**Verdict: ABRIDGE (-3 lines)**

The alternative flows are reasonable, but the "item becomes unavailable" flow (lines 105-108) describes a single edge case in 4 lines (including heading). Could be compressed to 2 lines. Font-size and leading overrides (lines 111-112) are formatting; not counted as content lines.

### 4.6 UC3: Order Management -- prose before figure (lines 117-128)

**Verdict: ABRIDGE (-5 lines)**

Lines 119-128 narrate flows that the table repeats. Line 120 ("the system requires staff authentication") is an obvious precondition already stated in the table's assumptions.

**Recommendation:** 1-2 sentences introducing the scenario. Let the table do the rest.

### 4.7 UC3: Order Management -- scenario table (lines 129-157)

**Verdict: KEEP**

This is the most concise of the three tables. The flows are clean and not overly detailed. No changes needed.

### Use Case Scenarios totals

| Subsection       | Verdict | Estimated saving |
| ---------------- | ------- | ---------------- |
| UC1 prose        | ABRIDGE | 8                |
| UC1 table        | ABRIDGE | 4                |
| UC2 prose        | ABRIDGE | 8                |
| UC2 table        | ABRIDGE | 3                |
| UC3 prose        | ABRIDGE | 5                |
| UC3 table        | KEEP    | 0                |
| **UCS subtotal** |         | **28 lines**     |

### Cross-file note: Use Case Scenarios vs Functional Requirements

The three UC scenarios collectively cover: Map Discovery, Heatmap, Order Placement, Cart Management, Payment, Order Tracking, and Restaurant Order Management. These are the same items listed in the FR chapter. However, the scenarios add genuine value by describing _flows_ and _alternatives_, so the overlap is acceptable. The key saving opportunity is the **prose introductions before each scenario table**, which simply pre-summarize the tables. The scenario tables themselves should stay; they are the expected deliverable for use-case-driven analysis.

---

## 5. `non-functional-requirements.typ` (30 lines)

### 5.1 Performance (lines 3-5)

**Verdict: KEEP**
Two specific, measurable targets (10K concurrent users, 3-second load time). Concise.

### 5.2 Security (lines 7-9)

**Verdict: ABRIDGE (-1 line)**

Line 9 ("Implement two-factor authentication for restaurant and customer accounts") -- is 2FA actually implemented? The system mocks payment (as stated in the UC scenarios), so it likely does not implement 2FA either. Requirements listed but not fulfilled invite evaluator criticism. If 2FA is not implemented, remove or add "future consideration" qualifier.

Additionally, AES-256 encryption is already implied by the GDPR/security discussion in `context.typ` (lines 25, 58-60). Consider cross-referencing rather than restating.

### 5.3 Scalability (lines 11-13)

**Verdict: ABRIDGE (-1 line)**

Line 12 ("seamless integration of additional features, such as loyalty programs or new payment methods") repeats `context.typ` line 54 ("future integration with Point of Sale systems") and `aims-and-objectives.typ` line 18 ("modular architecture ... loyalty programs or new payment gateways") almost verbatim. Keep one instance. Since the Aims chapter already states this objective, the NFR version should reference the quality attribute (modularity) without re-listing the same examples.

### 5.4 Availability (lines 15-17)

**Verdict: KEEP**
Specific, measurable targets (99.9% uptime, 2-hour recovery).

### 5.5 Usability (lines 19-21)

**Verdict: KEEP**
WCAG 2.1 reference with citation and 5-minute onboarding target. Specific and useful.

### 5.6 Maintainability (lines 23-25)

**Verdict: KEEP**
Reasonable and short.

### 5.7 Portability (lines 27-29)

**Verdict: ABRIDGE (-1 line)**

Line 29 ("Setup should not require technical expertise and should take less than 15 minutes") is a usability/deployment requirement, not a portability requirement. Either move it into the Usability section or remove it. The cross-platform requirement on line 28 is fine.

### Non-Functional Requirements totals

| Subsection          | Verdict | Estimated saving |
| ------------------- | ------- | ---------------- |
| Security (2FA line) | ABRIDGE | 1                |
| Scalability         | ABRIDGE | 1                |
| Portability         | ABRIDGE | 1                |
| Everything else     | KEEP    | 0                |
| **NFR subtotal**    |         | **3 lines**      |

---

## 6. `aims-and-objectives.typ` (27 lines)

### 6.1 Aim paragraph (lines 1-3)

**Verdict: ABRIDGE (-2 lines)**

The aim statement (line 3) says: "develop an order tracking and mobile order system tailored for small and medium-sized restaurants, particularly fast food outlets, that streamlines operations, enhances customer experience, and reduces dependency on expensive third-party solutions." This is nearly identical to `context.typ` lines 3-7. Since the Aims chapter is a required thesis section, keep it, but shorten the sentence since the Context chapter has already framed the problem.

### 6.2 Customer Experience Enhancement (lines 7-10)

**Verdict: KEEP**
Three specific bullets mapping to functional requirements. Appropriate level for objectives.

### 6.3 Restaurant Operations Optimization (lines 12-14)

**Verdict: KEEP**
Two bullets, concise.

### 6.4 Customization and Scalability (lines 16-18)

**Verdict: ABRIDGE (-1 line)**

Line 18 repeats the "modular architecture ... loyalty programs or new payment gateways" phrasing found in NFR Scalability (line 12) and `context.typ` (line 54). It is fine for objectives to state goals that NFRs then measure, but the parenthetical example list is redundant across three files. Remove the examples.

### 6.5 Cost Reduction (lines 20-21)

**Verdict: KEEP**
One sentence, project-specific. No changes needed.

### 6.6 Technical Robustness (lines 23-24)

**Verdict: REMOVE (-2 lines)**

Line 24 ("scalable, secure, and capable of handling many concurrent users without significant performance degradation") is a one-line summary of the entire NFR chapter. Since the NFR chapter exists and provides measurable targets, this objective adds no information. Remove or replace with a forward reference: "Meet the non-functional requirements defined in Chapter X."

### Aims and Objectives totals

| Subsection                    | Verdict | Estimated saving |
| ----------------------------- | ------- | ---------------- |
| Aim paragraph                 | ABRIDGE | 2                |
| Customization and Scalability | ABRIDGE | 1                |
| Technical Robustness          | REMOVE  | 2                |
| Everything else               | KEEP    | 0                |
| **Aims subtotal**             |         | **5 lines**      |

---

## Cross-Cutting Redundancy Summary

| Redundancy Pattern                  | Files Involved                                                                                                                         | Nature of Overlap                                                           |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Project motivation / business case  | `context.typ` (opening + Business Context), `aims-and-objectives.typ` (Aim paragraph, Cost Reduction)                                  | Same "small restaurants vs third-party platforms" argument stated 3-4 times |
| Heatmap feature                     | `functional-requirements.typ`, `aims-and-objectives.typ`, `context.typ` (Stakeholder expectations)                                     | Feature described at three levels in three files                            |
| Gamification / rewards              | `functional-requirements.typ`, `aims-and-objectives.typ`, `context.typ` (Stakeholder expectations)                                     | Mentioned in three places                                                   |
| Rating recalculation logic          | `functional-requirements.typ` (line 42), `use-case-diagram.typ` (line 62)                                                              | Identical description verbatim                                              |
| GDPR / encryption / security        | `context.typ` (External Factors + Industry Standards), `non-functional-requirements.typ` (Security)                                    | Data protection discussed in three locations                                |
| Scalability / future integrations   | `context.typ` (Integrations), `non-functional-requirements.typ` (Scalability), `aims-and-objectives.typ` (Customization & Scalability) | Nearly identical claims in three files                                      |
| UC scenario prose vs table          | `use-case-scenarios.typ` (all three UCs)                                                                                               | Each scenario's prose introduction pre-summarizes the table below           |
| UCD narrative vs FR vs UC scenarios | `use-case-diagram.typ` (Customer-Centric, Restaurant Management)                                                                       | Prose paraphrases both FRs and scenarios                                    |

---

## Unimplemented / Unmatched Requirements

These functional requirements have **no corresponding use case scenario or UCD element** and should be removed, marked out-of-scope, or moved to Future Work:

1. **Order Sharing** (`functional-requirements.typ`, lines 45-47) -- group orders, split payment, sharing links. No UC, no UCD.
2. **Dynamic Pricing and Promotions** (`functional-requirements.typ`, lines 68-70) -- happy hour deals, promotional campaigns. No UC, no UCD.
3. **Two-Factor Authentication** (`non-functional-requirements.typ`, line 9) -- no FR or UC supports this; payment is mocked.

---

## Grand Summary

| File                              | Current lines | Estimated saving | Reduced lines |
| --------------------------------- | ------------- | ---------------- | ------------- |
| `context.typ`                     | 61            | 30               | 31            |
| `functional-requirements.typ`     | 74            | 11               | 63            |
| `use-case-diagram.typ`            | 63            | 21               | 42            |
| `use-case-scenarios.typ`          | 157           | 28               | 129           |
| `non-functional-requirements.typ` | 30            | 3                | 27            |
| `aims-and-objectives.typ`         | 27            | 5                | 22            |
| **TOTAL**                         | **412**       | **~98**          | **~314**      |

**Estimated total reduction: ~98 source lines (approximately 24% of this group).**

---

## Top-Priority Actions (highest impact, lowest risk)

1. **Trim UC scenario prose introductions** (21 lines saved across three UCs). Every scenario has a multi-paragraph preamble that duplicates the structured table immediately below it. Replace each with 2-3 sentences.

2. **Compress UCD prose commentary** (16 lines saved). The diagrams are self-explanatory; the prose currently re-narrates what both the diagrams and the FR chapter already state. Replace with brief one-liner summaries per module.

3. **Consolidate Context opening + Business Context + Industry Standards** (14 lines saved). Three sections that say the same thing. Merge into one coherent opening section.

4. **Remove stakeholder expectation lists from Context** (6 lines saved). These are verbatim echoes of the Functional Requirements chapter. Replace with cross-references.

5. **Remove unimplemented FRs or move to Future Work** (6 lines saved). Order Sharing and Dynamic Pricing have no supporting UCs or UCD elements and weaken the document if left as formal requirements.

6. **Remove "Technical Robustness" objective and trim Aim paragraph** (4 lines saved). Redundant with the NFR chapter.
