/// Map a Swift type to its Kotlin/JVM equivalent.
///
/// Returns `nil` if the type is not supported, indicating the
/// enclosing declaration should be skipped.
func swiftTypeToKotlinType(_ type: SwiftType) -> String? {
  if type.isVoid {
    return "Unit"
  }

  guard let knownKind = type.asNominalTypeDeclaration?.knownTypeKind else {
    return nil
  }

  switch knownKind {
  case .int, .int64:
    return "Long"
  case .int32:
    return "Int"
  case .int16:
    return "Short"
  case .int8:
    return "Byte"
  case .uint, .uint64:
    return "ULong"
  case .uint32:
    return "UInt"
  case .uint16:
    return "UShort"
  case .uint8:
    return "UByte"
  case .bool:
    return "Boolean"
  case .double:
    return "Double"
  case .float:
    return "Float"
  case .string:
    return "String"
  case .void:
    return "Unit"
  default:
    return nil
  }
}
