# Requirement Traceability and Coverage Rules

The three-layer traceability loop is mandatory for V1.

## Source → Inventory: did we miss anything?

For every registered source and meaningful source unit:

1. Record a coverage state: analyzed, partially_analyzed, failed, or not_analyzed.
2. Record the disposition of meaningful content:
   - retained: extracted as requirement, context, rule, or dependency;
   - excluded: determined irrelevant to frontend, with a reason;
   - pending: ambiguous, conflicting, or missing information requiring a decision;
   - partial / failed: content could not be read or only partly reviewed, with affected scope.
3. Distinguish “analyzed and excluded” from “not analyzed”.
4. Do not mark a source unit analyzed based only on its title, outline, or a search snippet.

This layer must answer: where did the meaningful information in each source unit go?

## Inventory → Output: did extracted information disappear?

Every inventory item must have an output mapping:

- included: directly represented in a final requirement document;
- merged: combined with other records; retain all contributing IDs;
- referenced: represented by a canonical shared rule; target must resolve;
- excluded: omitted from final requirements with a reason;
- pending: not yet safely resolved; surface in open questions and quality report.

Validate that each target path and anchor exists. Check that merged/referenced content preserves every material condition. Do not let an item remain unmapped.

## Output → Source: is every formal requirement supported?

For every formal requirement in final documents, verify one of the following:

1. One or more valid source records support it.
2. It is explicitly marked inferred, with reasoning and supporting facts.
3. It is explicitly marked uncertain or conflicted and presented as unresolved, not confirmed.
4. It is a technical note strictly necessary to implement a confirmed behavior and is clearly separated from product requirements.

A plausible product convention is not evidence. Do not add undocumented UX behavior as a confirmed requirement.

## Many-to-many links

The model must support one source to multiple requirement records, multiple sources to one requirement record, one requirement to multiple final-document locations, and multiple requirement records to one merged passage.

Use stable source IDs, requirement IDs, and output targets. Text similarity alone is not traceability.

## Mapping ledger

analysis/requirement-mapping.md should be generated from or reconciled against the inventory. For each requirement ID, list source IDs, relevance, certainty, scope, mapping status, target(s), merged/referenced IDs, and exclusion/pending reason as applicable.

## No false closure

A loop is not closed merely because each file exists. Verify individual records and links. If a check cannot be completed due to unreadable material or unsupported output structure, record it as a limitation and reflect it in the overall quality result.
