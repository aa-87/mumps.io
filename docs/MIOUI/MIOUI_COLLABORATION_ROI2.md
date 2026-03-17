# MIOUI collaboration ROI 2

## Scope

This ROI adds reusable chat and message primitives on top of the identity layer from ROI 1.

It stays SSR-first.
It keeps the browser light.
It keeps the message model reusable across future workspace and billing integrations.

## Components

- chat header with participant strip
- incoming message bubble
- outgoing message bubble
- system event row
- date separator
- unread separator
- reply preview block
- quoted message block
- attachment tile
- reaction strip
- thread summary chip
- delivery state badge
- read state badge
- typing indicator row
- composer action bar
- side summary panels

## Variants

- standard chat
- dense chat
- balanced chat

All three variants reuse the same server-built message context.
The pages only change density and page composition.

## Test coverage

- route registration for all chat routes
- smoke render for all three chat pages
- builder contract checks for variant state and counts
- token coverage across all three variants for key message elements

## Synthetic data

All people, threads, files, and message content in this ROI are synthetic fixtures.
No real patient or source billing message content is used.
