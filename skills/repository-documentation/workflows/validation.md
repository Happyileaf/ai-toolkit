# Consistency Validation

Review the generated documentation before reporting completion.

## Factual grounding
- Verify important statements against the cited source paths and symbols.
- Ensure described entry points, modules, interfaces, dependencies, and flows exist.
- Check that inferred behavior is labeled as inference and unknowns remain explicit.

## Cross-document consistency
- Ensure module names, layer names, terms, and boundaries agree.
- Ensure the system overview, architecture, and flow descriptions tell a compatible story.
- Ensure glossary definitions match how terms are used elsewhere.

## Repository integrity
- Check relative links and referenced paths.
- Confirm generated files are under `docs/analysis/`.
- Confirm unrelated user files were not modified.
- Validate Mermaid syntax where a validator is available; otherwise inspect diagram structure manually and disclose that limitation.

Do not claim checks that were not run. Fix discovered inconsistencies and repeat the relevant checks.
