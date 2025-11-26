# Agents Guidance for Appcast Library Project

This file documents a guide for AI agents (GitHub Copilot, Claude Code) for the Appcast library project.

## Project Architecture

Appcast library is a Swift package to work with Sparkle compatible appcast files.
The code must target Swift 5.8 language features and follow strict concurrency rules.

Main source code is located at `Sources/Appcast` folder. The unit tests for Appcast
are located at `Tests/AppcastTests` folder.

Project includes integration tests at `Tests/IntegrationTests` to ensure it is
compatible with the original Sparkle implementation.
Never remove any integration test, even when it is failing.

### Instructions

These are the guidelines and rules that any AI agent (e.g. code assistants, refactoring bots, documentation helpers)
must follow when interacting with this project.

- The agent may read, generate, and modify Swift source files, tests, and package manifest `Package.swift`.
- The agent may update README, CHANGELOG, docs or examples.
- The agent should not modify license terms (`LICENSE.txt`).

- Follow Swift API design guidelines (naming, parameter labels, clarity).
- Minimize dependencies; lean implementation preferred.
- The agent should not introduce dependencies without explicit approval.

- Avoid speculation about domain knowledge it doesn't have; if unsure, mark for human review.


## Helpful Commands

- Build the code: `swift build`
- Run all tests: `swift test`
- Run Appcast unit tests only: `swift test --filter='AppcastTests'`
- Run integration tests only: `swift test --filter='IntegrationTests'`


## Related Projects

* [sparkle](https://github.com/sparkle-project/Sparkle): Original implementation for Appcast files
