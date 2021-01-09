//
//  ValueWasmer.swift
//  Wasmer / WebAssemblyWasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

/**
 * Map between `WebAssembly.Value` and `wasmer_value`.
 */
internal extension WebAssembly.Value {

  init(wasmerValue: wasmer_value_t) {
    switch WebAssembly.ValueType(wasmerValue.tag) {
      case .i32: self = .i32(wasmerValue.value.I32)
      case .i64: self = .i64(wasmerValue.value.I64)
      case .f32: self = .f32(wasmerValue.value.F32)
      case .f64: self = .f64(wasmerValue.value.F64)
    }
  }
  
  var wasmerValue: wasmer_value_t {
    set {
      switch WebAssembly.ValueType(newValue.tag) {
        case .i32: self = .i32(wasmerValue.value.I32)
        case .i64: self = .i64(wasmerValue.value.I64)
        case .f32: self = .f32(wasmerValue.value.F32)
        case .f64: self = .f64(wasmerValue.value.F64)
      }
    }
    get {
      let tag = valueType.wasmerRawValue
      switch self {
        case .i32(let value):
          return wasmer_value_t(tag: tag, value: .init(I32: value))
        case .i64(let value):
          return wasmer_value_t(tag: tag, value: .init(I64: value))
        case .f32(let value):
          return wasmer_value_t(tag: tag, value: .init(F32: value))
        case .f64(let value):
          return wasmer_value_t(tag: tag, value: .init(F64: value))
      }
    }
  }
}

extension Collection where Element == WebAssembly.Value {
  
  func makeRawValueArray() -> UnsafeMutableBufferPointer<wasmer_value_t> {
    let buffer = UnsafeMutableBufferPointer<wasmer_value_t>
                   .allocate(capacity: count)
    for ( idx, value ) in enumerated() {
      buffer[idx] = value.wasmerValue
    }
    return buffer
  }
}
