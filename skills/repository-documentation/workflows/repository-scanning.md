# Repository Scanning

Build a repository map before interpreting implementation.

Inspect:
- Top-level directories and representative nested files.
- Language and framework indicators.
- Package manifests, lockfiles, workspace configuration, and dependency declarations.
- Application/library entry points and exported interfaces.
- Build, test, lint, formatting, and development scripts.
- Environment and application configuration.
- Tests, fixtures, examples, migrations, schemas, and generated code.
- Deployment, container, CI, and runtime configuration where relevant.

Classify files as source, configuration, tests, documentation, generated output, vendored dependencies, or assets. Exclude large generated/vendor areas from routine inspection unless they define relevant behavior.

Identify project type from evidence, not repository naming. For monorepos, map each independently deployable or independently meaningful package and explain their relationships.
