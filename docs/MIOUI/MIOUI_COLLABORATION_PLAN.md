# MIOUI collaboration shift plan

## Direction

Build a reusable collaboration layer under `MIOUICOL*`.

This layer is not branded as social networking.
It is positioned as operator collaboration, presence, messaging, onboarding, and shared workspace context.

The billing surfaces can then consume these primitives later under `MIOUIBILL*`.

## Namespace

- routines: `MIOUICOL*`
- tests: `MIOUICOLT###`
- templates: `miouicol_*`

## ROI 1

Presence, avatars, and user bubbles.

Implemented in this ROI:
- presence groups
- user bubbles
- avatar stack
- assignee chips
- connected-user roster rows
- detail cards
- collaboration routes
- collaboration test runner

Routes:
- `/mioui/collab-presence`
- `/mioui/collab-avatars`
- `/mioui/collab-users`

## ROI 2

Chat primitives.

Implemented in this ROI:
- incoming message bubble
- outgoing message bubble
- system event row
- unread separator
- date separator
- reply preview
- quoted message block
- attachment stub tile
- reaction strip
- thread summary chip
- delivery and read states
- typing indicator
- composer action bar
- standard, dense, and balanced chat variants

Routes:
- `/mioui/collab-chat`
- `/mioui/collab-chat-dense`
- `/mioui/collab-chat-balanced`

## ROI 3

Onboarding surfaces.

Implemented in this ROI:
- onboarding summary shell
- dense onboarding review
- guided onboarding journey
- setup block cards
- invite preview roster
- launch readiness checklist
- launch and defaults panel
- starter room set cards
- reuse of user bubbles and connected-user preview in onboarding pages

Routes:
- `/mioui/collab-onboarding`
- `/mioui/collab-onboarding-dense`
- `/mioui/collab-onboarding-guided`

## Next ROIs

### ROI 4
Workspace shells.
- left conversation rail
- center chat or thread pane
- right context rail
- connected users panel
- participant stack
- thread navigator
- onboarding entry banners and first-run checkpoints

### ROI 5
Activity and notification surfaces.
- activity feed
- mention alerts
- watchlists
- assignment events
- escalation rows
- onboarding completion and adoption events

### ROI 6
Billing-integrated collaboration.
- claim discussion side panel
- denial review collaboration rail
- inline handoff history
- who-is-viewing strip
- assignee bubbles in work queues
- billing-specific onboarding for claim review teams

### ROI 7
Realtime-ready enhancement hooks.
- append zones
- polling-safe ids
- typing indicator targets
- unread refresh zones
- connected-user refresh regions
- onboarding state refresh targets
