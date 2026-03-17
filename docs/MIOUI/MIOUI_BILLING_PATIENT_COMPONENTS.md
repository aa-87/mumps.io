# MIOUI Billing Patient Components

This ROI now adds three patient-oriented billing review surfaces:

- `/mioui/billing-patient`
- `/mioui/billing-patient-dense`
- `/mioui/billing-patient-balanced`

## Goal

Create dense, readable SSR components for three billing review surfaces:

- claim detail
- transaction detail
- raw X12 loop and segment review

The second route is the densest operator workspace.
It is designed to keep the whole review experience on one screen using tabs and fixed-height panes.
The page itself is non-scrolling.
Individual dense panes can overflow internally when needed for large X12 content.

The third route is a balanced hybrid.
It keeps a readable claim overview ribbon and notes rail, then uses tabs for the deeper panes.
It is intended to sit between the long stacked review and the one-screen dense workspace.

## Source alignment

The three attached HTML files were used as the source of truth for:

- labels
- section nesting
- claim, transaction, and X12 groupings
- general density and information hierarchy

The implementation does **not** reuse the sample patient data from those files.
It uses fresh synthetic data with similar structure.

## Routes

- `GET /mioui/billing-patient`
- `GET /mioui/billing-patient-dense`
- `GET /mioui/billing-patient-balanced`

## New and updated routines

- `MIOUIBILL`
  - shared patient-oriented billing builders
  - claim header, fact, section, transaction, and X12 loop builders
- `MIOUIBILLD`
  - route registration
  - standard page builder
  - dense tabbed workspace builder
  - balanced hybrid workspace builder
  - page handlers for all three routes
- `MIOUIBILLT`
  - standalone test runner
- `MIOUIBILLT001`
  - builder contract coverage
- `MIOUIBILLT002`
  - route coverage and render coverage for all three routes
- `MIOUIBILLT003`
  - reference-element coverage for all three variants
- `MIOUIBILLT004`
  - balanced-variant builder and layout coverage

## Updated templates

- `templates/pages/miouibill_patient_review.html`
- `templates/pages/miouibill_patient_review_dense.html`
- `templates/pages/miouibill_patient_review_balanced.html`
- `templates/partials/miouibill_claim_snapshot.html`
- `templates/partials/miouibill_transaction_card.html`
- `templates/partials/miouibill_x12_explorer.html`

## Variant behavior

### Standard variant

The standard variant keeps the original stacked review flow:

- claim header and key facts first
- patient and party cards next
- service lines next
- raw X12 explorer last

It remains useful for long-form review and side-by-side scanning.

### Dense variant

The dense variant is designed to be at least twice as dense in practical use:

- fixed-height workspace container
- no page-level vertical scrolling
- tabbed panes for Claims, Transactions, and Raw X12
- compact key-fact ribbon
- compact cards and tables
- darker, higher-contrast light-theme text for readability

The dense view is intended for an operator who wants one-screen review and very fast switching between claim, line, and source-EDI perspectives.

### Balanced variant

The balanced variant mixes the two approaches:

- readable top summary ribbon
- quick links to the other variants
- operator notes visible without entering a separate pane
- tabbed switching for patient and parties, transactions, and raw X12
- roomier inner cards than the dense workspace
- more controlled scanning than the full stacked review

This variant is intended for operators who want structure and speed, but still want slightly more breathing room inside the deeper content panes.

## Reference coverage

The updated implementation now carries forward the major visible elements from all three reference files into **all three** variants.
That includes the claim labels, transaction labels, and X12 loop and segment structure.

Coverage now explicitly includes these areas from the references:

### Claim coverage

- Patient Ctrl Num (Claim ID)
- Charge Amt
- Place of Service
- Frequency
- Service Dates
- Provider Signature Indicator
- Assignment Participation Code
- Benefits Assignment Indicator
- Release of Information Code
- Key Info
- Insured Subscriber (Self, Primary)
- Payer
- Diagnoses
- Billing Provider
- Submitter
- Receiver
- EDI Transaction Info
- EDI File Info
- Employer's Identification Number
- File's Url

### Transaction coverage

- Charge Amt
- Units
- Place of Service
- Service Dates
- HCPCS Procedure
- Related Diagnosis
- Ordering Provider
- Name:
- NPI:
- Line 1 / Charge Amount: / Units:

### X12 coverage

- Transaction Set Header / Loop: 0000
- Submitter Name / Loop: 1000A
- Receiver Name / Loop: 1000B
- Billing Provider Hierarchical Level / Loop: 2000A
- Billing Provider Name / Loop: 2010AA
- Subscriber Hierarchical Level / Loop: 2000B
- Subscriber Name / Loop: 2010BA
- Payer Name / Loop: 2010BB
- Claim Information / Loop: 2300
- Service Line / Loop: 2400
- Drug Identification / Loop: 2410
- Ordering Provider Name / Loop: 2420E
- segment tokens including ST, BHT, SE, NM1, PER, HL, N3, N4, REF, SBR, DMG, CLM, HI, LX, SV1, DTP, LIN, and CTP

## Theme and readability

The pages use existing MIOUI layout primitives and Tailwind classes.
Light-theme text is intentionally darker than the source references so dense sections remain readable.
This remains especially important for the balanced and dense variants where a large amount of detail must stay visible without washing out in light mode.

## Test entry point

Run:

- `D ^MIOUIBILLT`

This remains separate from the main `^MIOUIT` runner so the billing work can iterate independently without disturbing the current numbered MIOUI suite.
