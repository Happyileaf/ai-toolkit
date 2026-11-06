# Frontend Requirements Document Structure

## Output layout

Use frontend-requirements/ by default:

~~~text
frontend-requirements/
├── README.md
├── analysis/
│   ├── source-index.md
│   ├── source-coverage.md
│   ├── document-structure.md
│   ├── business-context.md
│   ├── requirement-inventory.yaml
│   ├── cross-references.md
│   ├── requirement-mapping.md
│   ├── open-questions.md
│   └── quality-report.md
└── requirements/
    ├── README.md
    ├── shared-requirements.md
    └── <business-module>.md
~~~

Adapt file splitting to project size. Small projects may combine analysis records or modules; large projects may split modules further. Do not omit traceability information.

## Top-level README

Include purpose and scope of the analyzed change; concise business background and goals; frontend work-scope overview; module navigation; important cross-module rules/dependencies; links to analysis and quality report; and prominent unresolved issues that affect implementation.

## Module document

Recommended sections:

1. **Module overview** — purpose, boundaries, and role in the overall business flow.
2. **Required business context** — business objects, statuses, roles, permissions, and related modules.
3. **Pages and features** — page entry, layout/data display, filters, actions, interaction behavior, permissions, state-dependent behavior, and exceptions, only where supported by evidence.
4. **Module-level rules** — cross-page business rules, states, permissions, and data constraints.
5. **Dependencies** — APIs, backend responsibilities, external systems, and other modules; do not invent endpoint contracts.
6. **Open questions** — unresolved ambiguity/conflict that affects this module.
7. **Sources** — source IDs and requirement IDs, with links to analysis records where possible.

Organize by page when that makes behavior easier to understand. Cross-page flows and module-wide rules belong at module level. Do not force every requirement into a page.

## Shared requirements

Use shared-requirements.md only for genuinely cross-module rules such as common permissions, global states, shared interaction standards, or reusable data constraints. Module documents should reference the canonical rule rather than duplicate it.

## Writing standards

- Write for a frontend developer who did not attend product discussions.
- Be concrete about actor, preconditions, visible state, available action, outcome, and exception when the source defines them.
- Preserve business conditions and terminology.
- Separate confirmed requirements, inferences, and open questions visually and semantically.
- Keep technical implementation suggestions out of product requirement statements.
- Avoid copying large blocks of PRD text; reconstruct information and preserve source links.
- Do not fabricate page numbers, API names, field definitions, UI copy, or anchors.
