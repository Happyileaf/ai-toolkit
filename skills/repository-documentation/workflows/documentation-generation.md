# Documentation Generation

Generate documents from the consolidated analysis model, not from isolated file-reading notes.

Create:
- `docs/analysis/README.md`
- `docs/analysis/system-overview.md`
- `docs/analysis/architecture.md`
- `docs/analysis/business-flow.md`
- `docs/analysis/glossary.md`

Create `docs/analysis/diagrams/` and Mermaid `.mmd` sources when diagrams add explanatory value.

Writing requirements:
- Explain the actual implementation, not an idealized architecture.
- Introduce concepts before relying on them.
- Describe relationships and execution order explicitly.
- Link important claims to repository paths and symbols.
- Keep terminology consistent across all documents.
- Explain non-applicable sections briefly rather than inventing content.
- Mark unknowns and hypotheses visibly.
- Avoid duplicating entire sections across documents; use links and concise cross-references.
- Do not create a short README in place of the detailed system overview.

Use the templates in `templates/` as structural guidance. Adapt sections to the project rather than filling irrelevant headings mechanically.
