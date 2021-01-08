//
//  ValueType.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension WebAssembly {
  
  enum ValueType: Hashable {
    case i32
    case i64
    case f32
    case f64
  }
}

public extension WebAssembly.ValueType {

  @inlinable
  var stringValue: String {
    switch self {
      case .i32: return "i32"
      case .i64: return "i64"
      case .f32: return "f32"
      case .f64: return "f64"
    }
  }
}

extension WebAssembly.ValueType: CustomStringConvertible {
  
  @inlinable
  public var description: String { return stringValue }
}
