# Appcast library architecture

The Appcast library is a Swift package that implements a parser for the Appcast XML format
used by the Sparkle framework for macOS application updates.

## Source Code

The main source code for the Appcast library is located in the `Sources/Appcast` directory.

The library targets Swift 5.8 language version and uses strict concurrency model.


## Unit and Integration Tests

The library is tested by unit and integration tests located in the `Tests` directory.

The unit tests for the main Appcast code are located in the `Tests/AppcastTests` directory.

The integration tests for various Appcast files are located in the `Tests/IntegrationTests` directory.


## Links

Sparkle framework: https://github.com/sparkle-project/Sparkle
