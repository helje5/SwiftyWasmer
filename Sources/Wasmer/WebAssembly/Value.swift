//
//  Value.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension WebAssembly {
  
  /**
   * Stores a valid WebAssembly value.
   *
   * Note: Yes! It is only those types which are allowed in WebAssembly.
   *       There are not even strings.
   *       (IDL stuff may come in later)
   */
  enum Value: Hashable {
    case i32(Int32)
    case i64(Int64)
    case f32(Float)
    case f64(Double)
  }
}

public extension WebAssembly.Value { // MARK: - Convenience inits
  
  @inlinable init(_ value: Int32)  { self = .i32(value) }
  @inlinable init(_ value: Int64)  { self = .i64(value) }
  @inlinable init(_ value: Float)  { self = .f32(value) }
  @inlinable init(_ value: Double) { self = .f64(value) }
}

public extension WebAssembly.Value { // MARK: - Type
  
  @inlinable var valueType : WebAssembly.ValueType {
    switch self {
      case .i32: return .i32
      case .i64: return .i64
      case .f32: return .f32
      case .f64: return .f64
    }
  }
}

extension WebAssembly.Value: CustomStringConvertible {
  
  @inlinable
  public var description: String {
    switch self {
      case .i32(let value): return "i32(\(value))"
      case .i64(let value): return "i64(\(value))"
      case .f32(let value): return "f32(\(value))"
      case .f64(let value): return "f64(\(value))"
    }
  }
}
