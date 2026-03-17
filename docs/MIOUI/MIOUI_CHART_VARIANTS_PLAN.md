# MIOUI Chart Variants Plan

## Goal
Add a dedicated SSR-first chart and graph lab to MIOUI.

The page should show dense, operator-friendly chart surfaces without turning MIOUI into a client-heavy charting framework.

## Current ROI
This ROI keeps `/mioui/charts` under `MIOUIDEMO` and expands the chart lab with distribution and scoring variants.

It now includes these reusable chart families:
- horizontal bar comparisons
- stacked bar mixes
- line trends
- area forecast bands
- pie and donut summaries
- heatmap grids
- bullet and target comparisons
- funnel stage boards
- waterfall variance bridges
- histogram distributions
- box-range summaries
- radar score profiles
- sparkline comparison tables

## Design rules
- SSR first
- server-built view model
- partial-driven rendering
- dense and professional
- stable smoke-test tokens for chart actions
- no heavy browser state machine
- light and dark themes must both remain readable

## Callback token coverage
The page renders these action tokens explicitly:
- `openChartVariantStudio`
- `changeChartDateWindow`
- `switchChartGranularity`
- `toggleChartSeries`
- `filterChartPopulation`
- `compareChartSegments`
- `saveChartThresholds`
- `exportChartSnapshot`
- `pinChartToDashboard`
- `drillIntoChartPoint`
- `annotateChartRunRate`
- `cycleChartPalette`
- `rebaseVarianceBridge`
- `toggleDistributionBands`
- `changeBenchmarkOverlay`
- `switchRadarProfile`

## Good follow-up ROIs
- scatter and bubble plots for segment clustering and risk mapping
- timeline and milestone charts for workflow release tracking
- segmented dashboard layouts that combine charts with dense tables and profile cards
- chart + table composite review surfaces with synchronized filters
- chart collections specialized for billing leadership, collectors, and denial managers
