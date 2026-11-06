# Quality Checklist and Completion Criteria

## Required checks

### Source coverage

- [ ] Every input source is present in Source Index.
- [ ] Every meaningful source unit has a coverage state.
- [ ] Every analyzed unit has extracted information or an explicit exclusion disposition.
- [ ] Partial, failed, and not-analyzed units identify affected scope and reason.
- [ ] No source is considered analyzed merely because it was listed or outlined.

### Requirement coverage

- [ ] Every inventory record has an output mapping.
- [ ] Included targets exist.
- [ ] Merged mappings preserve all contributing requirement IDs and conditions.
- [ ] Referenced targets resolve to canonical shared rules.
- [ ] Excluded records have reasons.
- [ ] Pending records appear in open questions and the quality report.

### Output evidence

- [ ] Every formal requirement has one or more valid source references.
- [ ] Inferences identify their basis and remain labeled as inferred.
- [ ] Uncertain and conflicted items remain visibly unresolved.
- [ ] Technical notes are separated from product requirements.
- [ ] No undocumented interaction or business rule was added as confirmed.

### Consistency and links

- [ ] IDs are unique and stable.
- [ ] Referenced source and requirement IDs exist.
- [ ] Dependencies resolve or are explicitly external.
- [ ] Output paths and anchors exist.
- [ ] Certainty, frontend relevance, scope, and mapping status are consistent between inventory and final documents.
- [ ] Merged/referenced content has not lost material conditions.

### Document usability

- [ ] Final requirements are organized by business module.
- [ ] Necessary business context is present.
- [ ] Pages, features, shared rules, and cross-page behavior are placed sensibly.
- [ ] Roles, permissions, states, data dependencies, and exceptions are covered where sources define them.
- [ ] Open questions are easy to find and tied to affected requirements.
- [ ] Terminology is consistent.

## Explicit verification procedure

1. Walk the source index and source-unit ledger.
2. Walk every coverage row and verify its disposition.
3. Walk every requirement inventory record and verify its mapping.
4. Walk every formal requirement in final documents and verify its evidence or explicit status.
5. Compare status fields across inventory and output.
6. Resolve all IDs, dependencies, paths, and anchors.
7. Record failures, accepted limitations, and unresolved decisions in the quality report.

Do not substitute a general self-assessment or sample review for item-by-item checks. If the source set is too large to verify fully within available tools/context, disclose the exact unchecked portion and mark coverage partial.

## Severity

| Severity | Meaning |
|---|---|
| blocker | Critical input cannot be identified/read, preventing meaningful analysis of the target or core requirement |
| high | Key business-rule conflict, key module not analyzed, or a formal requirement lacks evidence |
| medium | Mapping gap, important missing context, or broken reference affecting understanding |
| low | Non-critical locator precision, wording, or organization issue |

An issue record should include issue_id, check_layer, severity, related_ids, description, impact, recommended_action, and status (open, resolved, accepted-limitation).

## Completion status

- **Completed**: all three traceability layers and consistency checks were executed; no undisclosed high-risk issue remains.
- **Completed with issues**: main analysis and checks are complete, but unresolved questions, partial coverage, or other disclosed issues remain.
- **Incomplete**: critical materials could not be read, a key analysis stage was not completed, or required traceability checks could not be performed reliably.

A run may complete with issues. Never hide, downgrade, or force-resolve an issue to obtain Completed.

## Reporting counts

Counts are useful when their denominator and counting rules are explicit. Avoid subjective completeness scores or unsupported percentages. If a percentage cannot be calculated from a well-defined source-unit/record set, omit it.
