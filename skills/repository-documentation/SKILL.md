---
name: repository-documentation
description: Analyze an existing software repository and produce a structured, evidence-based technical documentation set covering the system overview, architecture, business or operational flows, and glossary. Use when a user asks to understand, document, map, or explain an existing codebase. Do not use for implementing features, refactoring, or changing business code.
---

# Repository Documentation

Analyze the repository as it exists and generate a coherent technical documentation set. Treat source code as the primary evidence. Do not modify application code, refactor the system, or redesign its architecture.

## Operating principles

- Perform a full repository analysis for each run. Do not assume prior reports or Git diffs are a substitute for inspecting the current repository.
- Ground conclusions in implementation. Use configuration, tests, README files, comments, and package metadata as supporting evidence.
- Never invent behavior, dependencies, data models, or execution paths. Mark uncertain conclusions as unknown or clearly labeled hypotheses.
- Attach source paths and, where available, symbol names and line ranges to important claims.
- Separate observed facts from interpretation and recommendations. Do not turn documentation into an unsolicited architecture review.
- Build one consistent analysis model before generating documents so names, boundaries, and conclusions agree across outputs.
- Adapt analysis emphasis to the detected project type while retaining the common workflow.
- Keep generated documentation under `docs/analysis/`. Do not overwrite unrelated files.

## Deliverables

Generate the following documents:

1. `docs/analysis/system-overview.md` — a standalone, detailed explanation of the system's purpose, scope, major capabilities, users or consumers, runtime context, key concepts, and how the pieces work together. It should help a new reader understand the system without reading every source file, while providing pointers to implementation.
2. `docs/analysis/architecture.md` — system layers, modules, responsibilities, dependencies, entry points, data stores, external services, and important architectural boundaries.
3. `docs/analysis/business-flow.md` — important user/business scenarios and their execution sequences, branches, data transitions, and error handling. For projects without business workflows, document runtime or operational flows instead.
4. `docs/analysis/glossary.md` — domain terms, architectural concepts, technical keywords, abbreviations, and project-specific names.

Also generate `docs/analysis/README.md` as the documentation index. Include Mermaid source files in `docs/analysis/diagrams/` when diagrams materially clarify the system. Mermaid `.mmd` files are the authoritative editable diagram sources.

## Workflow

Follow the six stages in order. Consult the corresponding file in `workflows/` for detailed instructions.

1. **Repository Preparation** — identify the repository root, inspect the current branch and working-tree state, and understand remote synchronization before analysis. Do not switch branches, pull, reset, stash, or overwrite user changes without permission.
2. **Repository Scanning** — map the directory structure, identify project type(s), languages, frameworks, package manifests, entry points, configuration, scripts, tests, and deployment/runtime files. Exclude generated and vendored content unless it is relevant.
3. **System Analysis** — trace module responsibilities, imports and dependencies, public interfaces, execution paths, data structures, persistence, external integrations, and error handling.
4. **Knowledge Organization** — consolidate findings into a single internal model of system boundaries, modules, concepts, interfaces, and flows. Resolve naming inconsistencies and record evidence and uncertainty.
5. **Documentation Generation** — produce the four core documents, index, and useful diagrams from the consolidated model.
6. **Consistency Validation** — verify factual grounding, cross-document terminology, source paths, internal links, and Mermaid syntax. Correct inconsistencies before reporting completion.

## Project-type adaptation

Identify the repository's actual shape before choosing analysis emphasis. Use the common workflow and adapt its questions:

- **Frontend:** routes, pages, components, state management, browser APIs, network interfaces, and user interactions.
- **Backend:** application bootstrap, API endpoints, middleware, services, domain logic, persistence, queues, and integrations.
- **Full-stack:** frontend and backend structure plus their contracts and communication.
- **Library/toolkit:** public exports, capability units, APIs, dependency graph, supported environments, and usage patterns.
- **CLI:** executable entry points, command parsing, options, execution pipeline, output, and exit behavior.
- **SDK:** public API surface, client initialization, contracts, transport, errors, and examples.
- **Other or mixed projects:** infer the relevant runtime and component boundaries from repository evidence; do not force an unsuitable category.

## Diagram policy

Prefer diagrams that explain relationships or execution:

- System-level architecture and major external boundaries.
- Module-level dependencies or composition where useful.
- Business/runtime sequence and data flow for important scenarios.
- Code-level diagrams only when they materially clarify complex logic.

Use Mermaid and save source as `.mmd`. Keep diagrams readable, label relationships precisely, and ensure they match the written documents. Do not create diagrams merely to increase document volume.

## Scope boundaries

This skill documents the existing implementation. It does not implement features, modify business logic, refactor code, introduce dependencies, or propose a replacement architecture. If the user separately requests changes, treat that as a distinct task and obtain the required authorization.

## Completion report

When finished, summarize the repository and project type, list generated files, identify the most important source areas examined, and disclose unresolved questions or limitations. Do not claim a validation or inspection was performed unless it actually was.
