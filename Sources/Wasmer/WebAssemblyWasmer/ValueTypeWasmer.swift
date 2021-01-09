//
//  ValueTypeWasmer.swift
//  Wasmer / WebAssemblyWasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

internal extension WebAssembly.ValueType {

  init(_ value: UInt32) {
    switch value {
      case WASM_I32.rawValue: self = .i32
      case WASM_I64.rawValue: self = .i64
      case WASM_F32.rawValue: self = .f32
      case WASM_F64.rawValue: self = .f64
      default: fatalError("Invalid Wasm value tag \(value)")
    }
  }
  
  var wasmerRawValue: UInt32 {
    switch self {
      case .i32: return WASM_I32.rawValue
      case .i64: return WASM_I64.rawValue
      case .f32: return WASM_F32.rawValue
      case .f64: return WASM_F64.rawValue
    }
  }
}

extension Collection where Element == WebAssembly.ValueType {
  
  func makeRawValueArray() -> UnsafeMutableBufferPointer<UInt32> {
    let buffer = UnsafeMutableBufferPointer<UInt32>
                     .allocate(capacity: count)
    for ( idx, type ) in enumerated() {
      buffer[idx] = type.wasmerRawValue
    }
    return buffer
  }
}
