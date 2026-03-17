# MIOUI collaboration ROI 1

## Scope

This ROI establishes the shared identity layer for future collaboration work.

It stays SSR-first.
It uses server-built view models.
It keeps browser behavior minimal.

## Components

- top collaboration tabs
- hero stat strip
- presence group cards
- user bubbles
- connected-user rows
- user detail cards
- avatar stack
- assignee chips
- mini identity directory
- connected-user roster table
- collaboration info panels

## Themes

The light theme keeps darker text and clear borders.
The dark theme keeps readable muted text and status contrast.

## Test coverage

- route registration
- smoke render for all three routes
- token coverage for key identity labels and states

## Synthetic data

All displayed users are synthetic fixtures.
No real patient or billing source data is used in this collaboration layer.
