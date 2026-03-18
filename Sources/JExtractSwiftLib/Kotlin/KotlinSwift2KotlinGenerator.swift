import SwiftJavaConfigurationShared

/// Generates Kotlin/JVM stub source files from analyzed Swift declarations.
///
/// Currently supports top-level Swift functions only, emitting Kotlin
/// `fun` declarations with `TODO("Not implemented")` stub bodies.
package class KotlinSwift2KotlinGenerator: Swift2JavaGenerator {

  let logger: Logger
  let config: Configuration
  let analysis: AnalysisResult
  let swiftModuleName: String
  let kotlinPackage: String
  let outputKotlinDirectory: String

  package init(
    config: Configuration,
    translator: Swift2JavaTranslator,
    kotlinPackage: String,
    outputKotlinDirectory: String
  ) {
    self.config = config
    self.logger = Logger(label: "kotlin-generator", logLevel: translator.log.logLevel)
    self.analysis = translator.result
    self.swiftModuleName = translator.swiftModuleName
    self.kotlinPackage = kotlinPackage
    self.outputKotlinDirectory = outputKotlinDirectory
  }

  func generate() throws {
    try writeKotlinSources()
  }
}
