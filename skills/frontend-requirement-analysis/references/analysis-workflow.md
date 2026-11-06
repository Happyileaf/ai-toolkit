# Analysis Workflow and Source Handling

## Intake and source inventory

Record every supplied or explicitly in-scope source before deep analysis. Use stable SRC-NNN identifiers. Capture name/path, type, known version, modules, summary, relationships, readability, and limitations. Types may include PRD, supplement, prototype, screenshot, diagram, API, data dictionary, meeting note, review record, or other.

Model source relationships as supplements, revises, references, or conflicts. A later timestamp does not establish precedence. If the user has not established which version governs, preserve the ambiguity.

## Analysis units and coverage

Choose units that preserve meaning:

- PRD: section/subsection, requirement group, table, or rule block.
- Prototype: page, modal/drawer, interaction state, or scenario.
- Diagram: node, branch, transition, or sub-flow.
- API specification: operation, request/response field, error, or permission contract.
- Meeting/review notes: explicit decision, unresolved question, or action that changes requirement meaning.

Do not split mechanically by character count. If a unit is too large, split at semantic boundaries and retain its parent reference. Track each unit as analyzed, partially_analyzed, failed, or not_analyzed. Explain partial and failed states.

## Global then module-level synthesis

Global synthesis captures product goal, business objects, module boundaries, core workflows, roles, shared rules, cross-module dependencies, and source relationships. Module-level analysis then examines each source unit in detail. Global notes are not evidence that module details were reviewed.

## Long documents and context management

1. Inspect the complete table of contents or structural outline first.
2. Build a source-unit ledger before extraction.
3. Analyze units in manageable batches with source IDs and precise locators.
4. Persist extracted records and coverage changes to files rather than relying on conversational memory.
5. Maintain cross-reference links as each batch is processed.
6. After all units, perform a global reconciliation pass to find duplicated, related, contradictory, or unlinked information.

Never claim full coverage when only excerpts, search snippets, or a sample of sections were reviewed.

## Visual and partially readable materials

Treat prototypes, screenshots, and diagrams as independent sources. Record the pages/states/nodes actually inspected. If text is too small, cropped, missing, or inaccessible, record the affected portion and its impact. Do not infer exact UI copy, dimensions, or interaction behavior from an unreadable image.

## Conflict handling

For every material conflict, capture conflict ID and affected requirement IDs; each source and its statement/locator; the difference between statements; affected module/page/state and likely frontend impact; the exact decision needed; and status (open, resolved, or accepted-limitation).

Only mark a conflict resolved when the supplied materials or user explicitly establish the resolution. Preserve previous evidence in the analysis record.
