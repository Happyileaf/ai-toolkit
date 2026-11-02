# Project Type Guide

Use these profiles to adjust emphasis after scanning. A repository may combine several types.

| Type | Primary analysis targets |
|---|---|
| Frontend | Routes, pages, components, state, rendering, browser APIs, network contracts, interactions |
| Backend | Bootstrap, routes/controllers, middleware, services, domain logic, persistence, queues, integrations |
| Full-stack | Frontend and backend boundaries, shared contracts, authentication, data flow between tiers |
| Library/toolkit | Public exports, capability units, API contracts, dependency graph, supported runtimes, usage |
| CLI | Executable entry points, argument parsing, command dispatch, execution pipeline, output and exit codes |
| SDK | Client setup, public API, transport, serialization, errors, compatibility and examples |
| Monorepo | Workspace boundaries, package ownership, shared packages, build graph, deployment units |

For unfamiliar projects, derive a suitable profile from entry points, manifests, runtime configuration, and code structure. Do not force a category when the evidence indicates a different shape.
