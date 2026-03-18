# Getting Started with swift-java

This guide explains the project structure and how to get started extending it.

## What is this project?

**swift-java** enables bidirectional Swift & Java interoperability:

- **`wrap-java`** (Swift → Java): Generates Swift bindings that wrap Java classes, so Swift programs can call Java APIs directly.
- **`jextract`** (Java → Swift): Generates Java bindings from Swift libraries, so Java programs can call Swift code.

Two implementation strategies are available:

| Mode | Flag | Java Version | Use Case |
|------|------|-------------|----------|
| **FFM** | `--mode=ffm` (default) | JDK 25+ | Best performance, modern Java |
| **JNI** | `--mode=jni` | Java 7+ | Maximum compatibility (incl. Android) |

---

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Swift | 6.2+ | Install via [Swiftly](https://www.swift.org/install/) |
| JDK | 25+ | Required to **build**, even for JNI targets |
| Gradle | (bundled) | Use `./gradlew` — never install manually |

```bash
# Swift
swiftly install 6.2 --use

# Java (via sdkman)
sdk install java 25.0.1-amzn
sdk use java 25.0.1-amzn
export JAVA_HOME="$(sdk home java current)"
```

---

## Project Structure

### Top-level layout

```
swift-java/
├── Sources/              # All Swift source code (Swift Package Manager)
├── Tests/                # Swift tests
├── SwiftKitCore/         # Java module: core bridge (JNI-compatible)
├── SwiftKitFFM/          # Java module: FFM-based bridge (JDK 25+)
├── Samples/              # End-to-end sample applications
├── Benchmarks/           # Swift (package-benchmark) benchmarks
├── BuildLogic/           # Gradle convention plugins & build utilities
├── Plugins/              # Swift Package Manager compiler plugins
├── Package.swift         # Swift Package Manager manifest
├── settings.gradle.kts   # Gradle root settings
└── gradle.properties     # Gradle/Java configuration
```

### Build systems

The project uses **two build systems side by side**:

- **Swift Package Manager** — manages everything under `Sources/`, `Tests/`, `Plugins/`
- **Gradle (Kotlin DSL)** — manages `SwiftKitCore/`, `SwiftKitFFM/`, `Samples/`, `BuildLogic/`

They integrate at the boundary: Gradle tasks invoke Swift compilation, and sample apps depend on both Swift-built libraries and Gradle-built Java modules.

---

## Swift Modules (`Sources/`)

| Module | Purpose |
|--------|---------|
| `SwiftJava` | Core library with macros for Swift ↔ Java bridging |
| `SwiftJavaMacros` | Swift compiler plugin (macro implementations) |
| `SwiftJavaTool` | CLI entry point (`swift-java` command) |
| `SwiftJavaToolLib` | Shared logic for the CLI tool |
| `JExtractSwiftLib` | Java binding generation from Swift sources |
| `SwiftJavaRuntimeSupport` | Runtime support (cleanup, memory management) |
| `SwiftRuntimeFunctions` | Swift dynamic library loaded by Java at runtime |
| `JavaStdlib` | Generated Swift bindings for Java stdlib classes |
| `SwiftJavaConfigurationShared` | Shared config types |
| `ExampleSwiftLibrary` | Example Swift library used by samples |
| `SwiftJavaShared` | Shared utilities |
| `JavaKit` | Low-level Java interop primitives |
| `JavaKitDependencyResolver` | Maven/Gradle dependency resolution |
| `SwiftJavaDocumentation` | DoCC documentation sources |

### Dependency flow (simplified)

```
SwiftJavaTool
  ├── SwiftJavaToolLib
  │     ├── SwiftJava (macros + bridge)
  │     │     ├── SwiftJavaMacros (compiler plugin)
  │     │     └── SwiftJavaRuntimeSupport
  │     └── JExtractSwiftLib (jextract source generation)
  │           └── SwiftJavaConfigurationShared
  └── Commands: WrapJavaCommand, JExtractCommand, ResolveCommand, ConfigureCommand
```

---

## Java Modules (Gradle)

### `SwiftKitCore`

Located at `SwiftKitCore/src/main/java/org/swift/swiftkit/core/`.

Core abstractions that work with both FFM and JNI:

- `SwiftArena`, `SwiftMemoryManagement` — Swift object lifecycle management on the Java side
- `SwiftInstance`, `JNISwiftInstance` — Representations of Swift objects in Java
- `SwiftLibraries` — Loading Swift dynamic libraries
- `annotations/` — Java annotations for Swift interop
- `collections/`, `tuple/`, `ref/` — Data structure bridges

### `SwiftKitFFM`

Located at `SwiftKitFFM/src/main/java/org/swift/swiftkit/ffm/`.

FFM (Panama Foreign Function & Memory) implementations:

- `SwiftRuntime` — Main runtime entry point for FFM mode
- `SwiftHeapObject`, `FFMSwiftInstance` — FFM-based Swift object wrappers
- `SwiftValueWitnessTable`, `SwiftAnyType` — Swift type metadata access
- `SwiftValueLayout` — Memory layout definitions for Swift types

### `BuildLogic`

Convention plugins at `BuildLogic/src/main/kotlin/`:

- `build-logic.java-application-conventions.gradle.kts` — Shared config for Java apps
- `build-logic.java-library-conventions.gradle.kts` — Shared config for Java libraries
- `build-logic.java-common-conventions.gradle.kts` — Common Java settings
- `swiftPackageDescribe.kt` — Utilities for invoking SPM from Gradle
- `utilities/` — Helper functions for jextract integration and dependency resolution

---

## Swift Package Manager Plugins (`Plugins/`)

| Plugin | Purpose |
|--------|---------|
| `JavaCompilerPlugin` | Compiles Java sources as part of an SPM build |
| `SwiftJavaPlugin` | Generates Swift wrappers for Java classes |
| `JExtractSwiftPlugin` | Generates Java bindings from Swift during build |
| `PluginsShared` | Shared plugin utilities |

---

## Sample Applications (`Samples/`)

Each sample is a self-contained project with its own `build.gradle.kts` and/or SPM setup:

| Sample | Direction | Mode | What it shows |
|--------|-----------|------|---------------|
| `SwiftJavaExtractFFMSampleApp` | Java → Swift | FFM | Primary FFM example, includes JMH benchmarks |
| `SwiftJavaExtractJNISampleApp` | Java → Swift | JNI | JNI mode example |
| `JavaKitSampleApp` | Swift → Java | JNI | Swift calling Java libraries |
| `JavaDependencySampleApp` | Swift → Java | JNI | Maven dependency resolution from Swift |
| `SwiftAndJavaJarSampleLib` | Both | — | Packaging Swift+Java as a JAR |
| `JavaSieve` | Swift → Java | — | Sieve of Eratosthenes |
| `JavaProbablyPrime` | Swift → Java | — | Probabilistic primality testing |

Run any Gradle sample:
```bash
./gradlew :Samples:SwiftJavaExtractFFMSampleApp:run
```

Run any sample's CI validation:
```bash
cd Samples/SwiftJavaExtractFFMSampleApp
./ci-validate.sh
```

---

## Tests

### Swift tests

```bash
# All Swift tests
swift test

# Filter to a specific test target or method
swift test --filter JExtractSwiftTests

# XCTest only (skip swift-testing)
swift test --disable-experimental-swift-testing

# swift-testing only (skip XCTest)
swift test --disable-xctest
```

Test targets under `Tests/`:

| Target | Tests for |
|--------|-----------|
| `SwiftJavaTests` | Core SwiftJava library |
| `SwiftJavaMacrosTests` | Macro expansion correctness |
| `SwiftJavaToolLibTests` | CLI tool logic |
| `JExtractSwiftTests` | jextract source generation |
| `SwiftJavaConfigurationSharedTests` | Shared config |
| `LinkageTest` | Symbol linkage verification |

### Java tests

```bash
# All Java tests
./gradlew test

# Specific module
./gradlew :SwiftKitCore:test
./gradlew :SwiftKitFFM:test
```

> **Note:** Many runtime integration tests live inside `Samples/` because they depend on generated code. Check each sample's `ci-validate.sh`.

---

## Building

```bash
# Swift side
swift build                          # Build all Swift targets
swift build --target SwiftJavaTool   # Build just the CLI tool

# Java side
./gradlew build                      # Build all Java modules + samples
./gradlew :SwiftKitCore:build        # Build just SwiftKitCore
./gradlew build -PskipSamples=true   # Skip building samples

# Publish Java libs to local Maven repo (required for samples)
./gradlew publishToMavenLocal
```

### Using the CLI tool

```bash
swift build --target SwiftJavaTool
.build/debug/swift-java wrap-java --help
.build/debug/swift-java jextract --help
```

---

## Benchmarks

```bash
# Swift benchmarks (ordo-one/package-benchmark)
cd Benchmarks && swift package benchmark

# Java benchmarks (JMH)
./gradlew :Samples:SwiftJavaExtractFFMSampleApp:jmh
```

---

## How to Extend the Project

### Adding a new Swift module

1. Create a directory under `Sources/YourModule/`
2. Add the target in `Package.swift` under `targets:` and optionally `products:`
3. Declare dependencies on other targets as needed (e.g., `SwiftJava`, `JExtractSwiftLib`)
4. Add corresponding test target under `Tests/YourModuleTests/`

### Adding a new Java module

1. Create a directory at root level (e.g., `SwiftKitNewModule/`)
2. Add standard Gradle layout: `src/main/java/...`, `src/test/java/...`
3. Create `build.gradle.kts` applying the appropriate convention plugin:
   ```kotlin
   plugins {
       id("build-logic.java-library-conventions")
   }
   ```
4. Include it in `settings.gradle.kts`:
   ```kotlin
   include("SwiftKitNewModule")
   ```

### Adding a new sample

1. Create a directory under `Samples/YourSample/`
2. Add a `build.gradle.kts` (it will be auto-detected by `settings.gradle.kts`)
3. Add a `ci-validate.sh` script for CI testing
4. Depend on `SwiftKitCore` / `SwiftKitFFM` as needed

### Modifying jextract code generation

The source generation logic lives in:
- `Sources/JExtractSwiftLib/` — Swift → Java binding generation
- `Sources/SwiftJavaToolLib/` — Java → Swift binding generation (wrap-java)

Generated output typically goes into `src/generated/java` in sample apps.

### Modifying macros

Swift macros are in `Sources/SwiftJavaMacros/`. Test them via `Tests/SwiftJavaMacrosTests/`. Macros are compiler plugins, so changes require a rebuild of the package.

### Modifying Gradle build logic

Convention plugins live in `BuildLogic/src/main/kotlin/`. Changes there affect all Java modules and samples that apply the conventions.

---

## Kotlin JVM Code Generation (Experimental)

swift-java can generate Kotlin/JVM stub code from Swift sources using `--lang kotlin-jvm`.

### Usage

```bash
swift build --target SwiftJavaTool

.build/debug/swift-java jextract \
    --swift-module MySwiftLibrary \
    --input-swift Sources/MySwiftLibrary \
    --output-swift /tmp/out-swift \
    --output-java /tmp/out-kotlin \
    --lang kotlin-jvm
```

This generates `.kt` files with `TODO("Not implemented")` stub bodies for all top-level public Swift functions.

### Supported Type Mappings

| Swift Type | Kotlin Type |
|---|---|
| `Int` / `Int64` | `Long` |
| `Int32` | `Int` |
| `Int16` | `Short` |
| `Int8` | `Byte` |
| `Bool` | `Boolean` |
| `Double` | `Double` |
| `Float` | `Float` |
| `String` | `String` |
| `Void` | `Unit` |

Functions using unsupported types (e.g., custom classes, pointers) are silently skipped.

### Example

Given Swift input:
```swift
public func greet(name: String) -> String
public func add(a: Int32, b: Int32) -> Int32
```

Generated Kotlin output:
```kotlin
// Generated by jextract-swift
// Swift module: MySwiftLibrary

package com.example.swift

fun greet(name: String): String {
    TODO("Not implemented")
}

fun add(a: Int, b: Int): Int {
    TODO("Not implemented")
}
```

### Running the Tests

```bash
swift test --filter KotlinGlobalFunctionTests
```

---

## CI/CD

GitHub Actions workflows run on every PR (`.github/workflows/pull_request.yml`):

- **Soundness**: formatting, license headers, documentation
- **Swift tests**: against Swift 6.1.3, 6.2, nightly
- **Java tests**: SwiftKitCore and SwiftKitFFM with JDK 25
- **Sample validation**: each sample's `ci-validate.sh`
- **Benchmarks**: compilation verification
- **Android**: cross-compilation for aarch64, x86_64, armv7

Run CI checks locally with [act](https://github.com/nektos/act):
```bash
act pull_request
act workflow_call -j soundness --input format_check_enabled=true
```

---

## Key Links

- [WWDC25 Introduction Video](https://www.youtube.com/watch?v=QSHO-GUGidA)
- [DoCC Documentation](http://localhost:8080/documentation/documentation) (after running `xcrun docc preview`)
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to submit patches and bug reports
