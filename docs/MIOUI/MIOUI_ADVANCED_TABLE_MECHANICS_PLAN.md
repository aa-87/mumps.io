# MIOUI Advanced Table Mechanics Plan

## Goal

Move the large-table system beyond paging and filters into operator-grade advanced mechanics that still keep the server authoritative.

## Components in this step

- `mioui_multi_sort_stack.html`
- `mioui_virtual_window_navigator.html`
- `mioui_column_resize_ruler.html`
- `mioui_row_group_bands.html`
- `mioui_subtotal_band.html`
- `mioui_right_frozen_summary.html`

## Builder routine

- `MIOUITMX.m`

## Demo route

- `/mioui/advanced-table`

## Contract shape

The page is shaped entirely on the server. No browser ownership is assumed for:

- sort priority
- active window
- persisted widths
- grouping key
- subtotal values
- frozen summary values

## Why this ROI matters

Dense billing and audit applications need more than paging. They need reusable mechanics that let an operator stay oriented while working across very wide and very large queues.
