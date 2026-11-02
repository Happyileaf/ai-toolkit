# System Analysis

Trace how the system actually works.

1. Identify startup paths, public entry points, and runtime lifecycle.
2. Group source files into modules by responsibility and observed dependency boundaries.
3. Trace important imports, calls, events, messages, and API boundaries.
4. Identify data structures, schemas, persistence mechanisms, caches, and state ownership.
5. Inspect external services, network calls, filesystem access, browser/platform APIs, and third-party integrations.
6. Trace representative success, validation, failure, retry, and cleanup paths.
7. Use tests to corroborate behavior, not as a substitute for implementation.
8. Record evidence for each significant conclusion, including file paths and symbols; include line ranges when available.

Do not infer runtime behavior solely from filenames or comments. If static inspection cannot establish a behavior, label it unknown or a hypothesis.
