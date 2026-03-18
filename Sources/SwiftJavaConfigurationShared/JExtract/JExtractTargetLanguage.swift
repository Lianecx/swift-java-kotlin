//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift.org project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift.org project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

/// Determines which target language JExtract should generate bindings for.
public enum JExtractTargetLanguage: String, Sendable, Codable {
  /// Generate Java source files (default).
  case java

  /// Generate Kotlin/JVM source files.
  case kotlinJvm = "kotlin-jvm"

  public static var `default`: JExtractTargetLanguage {
    .java
  }
}
