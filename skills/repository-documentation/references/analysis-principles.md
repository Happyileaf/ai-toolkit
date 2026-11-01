# Analysis Principles

## Evidence hierarchy
Use implementation source as primary evidence. Use tests to confirm expected behavior, configuration and manifests to establish declared setup, and README/comments as context. Documentation may be stale; verify important claims against code.

## Traceability
For important conclusions, include a relative path and the relevant symbol. Add line ranges when the inspection environment provides stable line numbers. Prefer a small number of precise references over a long undifferentiated file list.

## Confidence
- **Observed:** directly established by implementation or configuration.
- **Inferred:** strongly suggested by multiple pieces of evidence but not directly explicit.
- **Unknown:** repository evidence is insufficient.

Do not silently promote inferred or unknown details into facts.

## Boundaries
Describe the current system and its actual dependencies. Do not redesign it, grade it, or propose refactors unless separately requested.

## Full analysis
Re-scan the current repository on each run. Existing generated documents are useful context but are not authoritative evidence and must be revalidated.
