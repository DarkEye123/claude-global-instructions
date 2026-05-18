# Trim Defensive Code

Use this skill when the user wants an implementation simplified because it is too defensive, too abstract, or stronger than the requirement.

## Goal

Reduce code to the smallest shape that still satisfies the real product requirement.

## Workflow

1. Restate the actual requirement in one sentence.
2. Identify which behavior is required vs which behavior is merely defensive.
3. Remove or shrink the strongest non-required mechanism first.
4. Keep public APIs and tests aligned to required behavior, not implementation details.
5. Re-run validation and check whether any remaining complexity is still justified.

## Heuristics

- Prefer a local rule over a generalized engine.
- Prefer private helpers over exported helpers created only for tests.
- Prefer black-box tests over white-box tests when the helper is not a real module boundary.
- Do not preserve tie-break ordering, caching behavior, or fallback semantics unless they are required or clearly valuable.
- Do not couple render-order logic to payload/data-shaping logic unless the requirement explicitly needs both.
- If a test locks in stronger behavior than the requirement, relax or remove that assertion.

## Common Smells

- Abstractions introduced only to make internals testable
- Global utility changes for a narrow view-level requirement
- Extra ordering guarantees such as sibling stability or backend-order preservation without product need
- Defensive caches, maps, queues, or graph logic where a direct pass would do
- Public API surface that exists only because tests need access

## Questions To Ask

- What exact user-visible behavior are we protecting?
- If this extra logic is removed, what real bug returns?
- Is this a product requirement or just an implementation preference?
- Are tests proving behavior or pinning internal structure?

## Output Style

When reporting findings or proposing simplifications:

- name the narrow requirement first
- call out the specific over-defensive mechanism
- recommend the smallest viable replacement
- mention which tests should be kept, relaxed, or deleted
