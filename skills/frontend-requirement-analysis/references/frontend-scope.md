# Frontend Relevance and Scope Rules

## Frontend relevance

| Value | Meaning | Treatment |
|---|---|---|
| direct | Frontend directly implements the page, display, interaction, or client behavior | Include in frontend requirements |
| collaborative | Frontend behavior depends on backend data, APIs, states, or a shared contract | Describe frontend responsibility and collaboration/dependency |
| contextual | Not implemented by frontend, but needed to understand display, permissions, actions, or state | Preserve as business context or referenced rule |
| irrelevant | Does not affect frontend scope, behavior, dependency, or understanding | Record exclusion and reason in analysis; normally omit from final requirements |

Judge by impact on frontend understanding and behavior, not by whether the source describes frontend or backend technology. Backend-owned order states can be contextual; internal service implementation may be irrelevant.

## Certainty

| Value | Meaning | Writing rule |
|---|---|---|
| confirmed | Explicitly stated or supported by an authoritative, verifiable source | May be stated as a formal requirement with source references |
| inferred | Derived from multiple known facts but not explicitly stated | Label as inference and state its basis; do not present as confirmed |
| uncertain | Insufficient information or ambiguous wording | Mark as open question; do not fill the gap with convention |
| conflicted | Sources disagree about the same rule or behavior | Preserve competing evidence and ask for a decision |

Certainty is not priority. Plausibility does not turn an inference into a confirmed requirement.

## Scope

| Value | Meaning |
|---|---|
| new | The source explicitly says this capability/behavior is being added |
| modify | The source explicitly says an existing capability/behavior changes |
| retain | The source explicitly says existing behavior remains unchanged or is not adjusted |
| out-of-scope | The source explicitly excludes this capability from the delivery |
| unknown | The material does not establish the current state or delivery treatment |

Rules:
- Not mentioned does not mean nonexistent.
- No description of current state does not mean already implemented.
- Do not infer new, modify, retain, or out-of-scope from common product patterns.
- Without code/repository analysis, do not claim the current implementation was verified.
- Use unknown when evidence is insufficient and surface it when it affects planning or implementation.

## Do not invent product behavior

If a source only says “submit for approval”, do not silently add loading indicators, duplicate-submit prevention, automatic navigation, modal presentation, automatic list refresh, or success/failure messaging as formal requirements. These are product decisions unless an applicable source or established design standard explicitly specifies them.

Separate explicit product behavior, technical handling strictly necessary to implement that behavior, and unspecified product interaction that needs a decision. Only the first is a confirmed product requirement. Explain the second as implementation context. Record the third as an open question or explicitly labeled suggestion, never as a confirmed requirement.

## Permission, state, and backend context

Retain backend-owned facts when they affect frontend behavior. Examples include role-to-action permission, status transition constraints, operation eligibility, server-side validation, and data ownership. Describe what frontend must display or make available, and identify the backend contract without inventing endpoint details.
