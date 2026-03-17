# MIOUI Billing Patient Components

This billing UI ROI now covers both patient-review and billing-report surfaces:

- `/mioui/billing-patient`
- `/mioui/billing-patient-dense`
- `/mioui/billing-patient-balanced`
- `/mioui/billing-reports`
- `/mioui/billing-reports-dense`
- `/mioui/billing-reports-executive`
- `/mioui/billing-reports-analytics`
- `/mioui/billing-reports-wallboard`
- `/mioui/billing-reports-forecast`
- `/mioui/billing-reports-benchmark`
- `/mioui/billing-reports-cashflow`
- `/mioui/billing-reports-denials`

## Goal

Create dense, readable SSR components for two billing review modes:

- patient and claim inspection
- report and supervisor monitoring

The patient routes remain focused on claim detail, transactions, and raw X12 trace.
The report routes shift to revenue-cycle supervision and aggregate the same billing work into multiple report rhythms rather than one single dashboard shape.

## Patient review surfaces

The patient-oriented routes keep the behavior from the previous ROI:

- a standard stacked review
- a one-screen dense workspace
- a balanced hybrid route

Those routes still preserve the claim, transaction, and X12 labels and structure from the three attached HTML references.
They still use fresh synthetic data instead of the sample data from those source files.

## Billing reports family

The report routes are now:

- `GET /mioui/billing-reports`
- `GET /mioui/billing-reports-dense`
- `GET /mioui/billing-reports-executive`
- `GET /mioui/billing-reports-analytics`
- `GET /mioui/billing-reports-wallboard`
- `GET /mioui/billing-reports-forecast`
- `GET /mioui/billing-reports-benchmark`
- `GET /mioui/billing-reports-cashflow`
- `GET /mioui/billing-reports-denials`

All nine report routes share the same core revenue-cycle data model:

- report header with refresh status and report period
- dense filter ribbon for facility, payer scope, and queue context
- KPI grid for gross charges, collections, first-pass rate, aged A/R, denials, and posted cash
- aging-bucket table
- payer performance table
- top denial-reason stack
- scheduled export queue
- operator watch notes

The difference is the page rhythm and operator intent.

### Standard workspace

`/mioui/billing-reports` remains the balanced baseline for general supervision.
It keeps KPI cards at the top and uses tabs for Summary, Aging, Payers, and Exports.

### Dense console

`/mioui/billing-reports-dense` is the next ROI delivered in this pass.
It is a queue-first operator console with:

- smaller KPI cells
- fixed-height workspace layout
- compact filter ribbon
- left-rail recovery lanes
- center tabbed panes for queues, aging, payers, and exports
- right-rail daily collections trend strip

This variant is meant for leads and operators who stay close to queue ownership and need a tighter, more scan-oriented surface.

### Executive snapshot

`/mioui/billing-reports-executive` is the presentation-oriented companion route.
It keeps the same billing metrics but changes the hierarchy toward:

- calmer header rhythm
- leadership-friendly KPI presentation
- narrative story cards
- named next-action stack
- dense supporting payer, denial, aging, and export panels

This variant is meant for weekly review, stakeholder walkthroughs, and leadership syncs that still need real billing detail in the same SSR shell.


### Analytics studio

`/mioui/billing-reports-analytics` shifts the report family toward visual scanning.
It keeps the same synthetic billing signals, but emphasizes chart surfaces such as:

- a collection-goal metric ring
- a seven-day collections column graph
- a payer mix and variance horizontal graph
- an aging distribution stacked band
- a denial heatmap
- a clean-claim funnel

This route is meant for supervisors and analysts who want trend and concentration patterns before they open deeper tables.

### Visual wallboard

`/mioui/billing-reports-wallboard` is the monitor-friendly companion to the analytics studio.
It uses the same chart primitives but arranges them into a shared-space wallboard rhythm for:

- command-center monitors
- shift huddles
- floor displays
- high-level visual scanning in light or dark theme

The wallboard remains SSR-first and does not depend on a browser chart library.

### Forecast studio

`/mioui/billing-reports-forecast` extends the chart family into forward-looking supervision.
It adds:

- a six-week cash projection band
- constrained, commit, and stretch scenario cards
- a projected cash bridge that shows drag and upside factors
- the existing KPI, denial, and export primitives underneath

This route is meant for planning meetings, staffing discussions, and weekly expectation-setting where the next few weeks matter more than the prior few days.

### Benchmark deck

`/mioui/billing-reports-benchmark` turns the report family toward comparison and ranking.
It adds:

- a peer-versus-internal benchmark ladder
- a payer-family benchmark matrix
- payer ranking scorecards
- the existing payer, denial, and aging tables as support detail

This route is meant for operational review, payer-performance comparison, and identifying which metrics are above peer median but still below top-quartile posture.


### Cashflow studio

`/mioui/billing-reports-cashflow` turns the report family toward posted-cash motion.
It adds:

- an eight-period posted-cash run-rate graph
- cash-source mix lanes for ERA, lockbox, manual posting, and rebill recovery
- payer remit-lag tracks for the highest-impact payer groups
- the existing payer, KPI, and export primitives underneath

This route is meant for supervisors and leads who need to understand how cash is arriving, not only how much has been collected.

### Denial intelligence

`/mioui/billing-reports-denials` turns the report family toward denial pressure and appeal posture.
It adds:

- a denial reason stream with open, appealed, and closed posture
- a payer-risk matrix crossing denial family with payer family
- an appeal-aging ladder for stale denial detection
- the existing denial, payer, and aging tables as support detail

This route is meant for denial managers, appeal leads, and queue owners who need reason concentration and stale-case pressure to read quickly.

## New and updated routines

- `MIOUIBILL`
  - still provides patient-oriented claim, transaction, and X12 builders
  - provides report builders for header, filters, KPIs, tabs, aging rows, payer rows, denial bands, export jobs, and watch notes
  - now also provides variant-specific builders for dense queue lanes, daily trend bars, executive story cards, and named actions
- `MIOUIBILLD`
  - still registers and serves the three patient routes
  - serves the standard report route plus the dense and executive report variants
  - now builds the shared report context and the variant-specific overlays
- `MIOUIBILLT`
  - standalone billing test runner
- `MIOUIBILLT001`
  - patient builder contract coverage
- `MIOUIBILLT002`
  - route coverage and render coverage for patient routes and all report routes
- `MIOUIBILLT003`
  - reference-element coverage for all patient variants
- `MIOUIBILLT004`
  - balanced patient variant coverage
- `MIOUIBILLT005`
  - report builder contract coverage for the standard report workspace
- `MIOUIBILLT006`
  - standard report render coverage
- `MIOUIBILLT007`
  - report variant builder coverage for dense and executive routes
- `MIOUIBILLT008`
  - report variant render-token coverage for dense and executive routes
- `MIOUIBILLT009`
  - builder coverage for analytics studio and wallboard variants
- `MIOUIBILLT010`
  - render-token coverage for analytics studio and wallboard variants
- `MIOUIBILLT011`
  - builder coverage for forecast and benchmark report variants
- `MIOUIBILLT012`
  - render-token coverage for forecast and benchmark report variants
- `MIOUIBILLT013`
  - builder coverage for cashflow and denial-intelligence report variants
- `MIOUIBILLT014`
  - render-token coverage for cashflow and denial-intelligence report variants

## Updated and new templates

### Existing patient templates still in use

- `templates/pages/miouibill_patient_review.html`
- `templates/pages/miouibill_patient_review_dense.html`
- `templates/pages/miouibill_patient_review_balanced.html`
- `templates/partials/miouibill_claim_snapshot.html`
- `templates/partials/miouibill_transaction_card.html`
- `templates/partials/miouibill_x12_explorer.html`

### Report templates

- `templates/pages/miouibill_reports.html`
- `templates/pages/miouibill_reports_dense.html`
- `templates/pages/miouibill_reports_executive.html`
- `templates/pages/miouibill_reports_analytics.html`
- `templates/pages/miouibill_reports_wallboard.html`
- `templates/pages/miouibill_reports_forecast.html`
- `templates/pages/miouibill_reports_benchmark.html`
- `templates/pages/miouibill_reports_cashflow.html`
- `templates/pages/miouibill_reports_denials.html`
- `templates/partials/miouibill_report_kpi_grid.html`
- `templates/partials/miouibill_report_aging_table.html`
- `templates/partials/miouibill_report_payer_table.html`
- `templates/partials/miouibill_report_denial_bands.html`
- `templates/partials/miouibill_report_export_queue.html`
- `templates/partials/miouibill_report_queue_board.html`
- `templates/partials/miouibill_report_trend_strip.html`
- `templates/partials/miouibill_report_story_cards.html`
- `templates/partials/miouibill_report_action_stack.html`
- `templates/partials/miouibill_chart_meter.html`
- `templates/partials/miouibill_chart_columns.html`
- `templates/partials/miouibill_chart_horizontal_bars.html`
- `templates/partials/miouibill_chart_stacked_band.html`
- `templates/partials/miouibill_chart_heatmap.html`
- `templates/partials/miouibill_chart_funnel.html`
- `templates/partials/miouibill_chart_projection_band.html`
- `templates/partials/miouibill_chart_waterfall.html`
- `templates/partials/miouibill_report_scenario_cards.html`
- `templates/partials/miouibill_chart_benchmark_ladder.html`
- `templates/partials/miouibill_chart_peer_matrix.html`
- `templates/partials/miouibill_report_benchmark_scorecards.html`
- `templates/partials/miouibill_chart_runrate_strip.html`
- `templates/partials/miouibill_chart_source_mix.html`
- `templates/partials/miouibill_chart_lag_timeline.html`
- `templates/partials/miouibill_chart_denial_stream.html`
- `templates/partials/miouibill_chart_denial_matrix.html`
- `templates/partials/miouibill_chart_appeal_ladder.html`

## Report design principles

The report family follows the same MIOUI guardrails as the patient surfaces:

- SSR first
- minimal browser enhancement
- dense but readable light-theme contrast
- server-built view model
- reusable partials
- stable tables and predictable panel rhythm

The new variants do not introduce a new client-side dashboard framework.
They reuse the same report data while changing only the layout choreography.

## Report data model

The report surfaces use fresh synthetic billing data.
It is intentionally similar to real billing supervision data, but it is not copied from external samples.

The current report family includes:

- five filters
- six KPI cards
- five aging buckets
- five payer rows
- four denial reasons
- three scheduled export jobs
- three operator watch notes
- four dense queue lanes
- six dense trend bars
- three executive story cards
- three executive next actions
- one metric ring
- seven collections trend bars
- five payer graph rows
- five aging distribution segments
- sixteen denial heat cells
- six forecast weeks
- three forecast scenario cards
- six bridge steps
- five benchmark ladders
- sixteen benchmark matrix cells
- four benchmark payer scorecards
- four clean-claim funnel stages

## Theme and readability

All report variants follow the same light-theme guardrail as the patient pages.
Text remains darker and more contrast-heavy than many dashboard examples so dense grids, tables, labels, and tabs remain readable in light mode.

## Test entry point

Run:

- `D ^MIOUIBILLT`

The billing test runner remains separate from the main `^MIOUIT` runner so billing-specific work can continue to evolve independently.

The cashflow and denial variants keep the same SSR-first model, but bias the layout toward run-rate, lag, appeal posture, and concentration scanning rather than general supervision alone.


## Productivity and underpayments ROI

This ROI adds two more billing-report variants:

- ` /mioui/billing-reports-productivity`
- ` /mioui/billing-reports-underpayments`

The productivity studio is built for billing leads who want team throughput to be visible without opening a separate workforce dashboard.
It adds:

- five team touch bars
- sixteen queue heat cells
- four leaderboard cards
- six backlog slope points

The underpayments studio is built for reimbursement variance review.
It adds:

- five waterfall steps
- four payer leakage lanes
- sixteen contract variance cells
- four leakage story cards

Both variants stay SSR-first and use the same darker light-theme treatment as the rest of the billing family so dense chart labels remain readable.
