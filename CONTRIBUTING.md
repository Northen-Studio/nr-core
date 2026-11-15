# Contributing

Keep changes focused and describe the user-visible problem and resulting
behaviour. Include reproduction steps and exact FXServer/framework/provider
versions. Preserve the stable public exports and use British English in docs.

Use four spaces, UTF-8 and LF endings. Keep integrations in their own adapters.
Avoid new globals beyond Config and the resource-local NR namespace, permanent
polling, implicit dependencies and raw player data in logs. Do not add unfinished
exports for future modules.

Run `node tests/run.cjs` after installing the documented development runtime.
Add regression checks for meaningful behavioural changes. For API changes,
verify signatures against upstream official documentation or source and update
docs/references.md. Report which live checks from docs/testing.md were performed.

Security issues should be reported privately to the repository maintainers
through GitHub's private security reporting if enabled. Do not publish player
identifiers, tokens, credentials or working abuse instructions in public issues.

Contributions are distributed under the project's MIT licence.
