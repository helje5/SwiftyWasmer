//
//  ExportFuncPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafePointer where Pointee == wasmer_export_func_t {
  
  /**
   * Returns the number of parameters the exported function expects.
   */
  var parameterCount : Int {
    return Int(apiInvoke(wasmer_export_func_params_arity, on: self))
  }
  
  /**
   * Returns the number of return values the exported function returns.
   */
  var returnValueCount : Int {
    return Int(apiInvoke(wasmer_export_func_returns_arity, on: self))
  }
  
  /**
   * Returns the parameter types the exported function expects,
   * as `WebAssembly.ValueType` values.
   * 
   * There are only four value types allowed in Wasm functions: 
   * `.i32`, `.i64`, `.f32` and `.f64`.
   */
  var parameterTypes : [ WebAssembly.ValueType ] {
    return apiInvoke(wasmer_export_func_params,
                     with: parameterCount, on: self)
    {
      return WebAssembly.ValueType($0)
    }
  }
  
  /**
   * Returns the types of the values the exported function returns,
   * as `WebAssembly.ValueType` values.
   * 
   * There are only four value types allowed in Wasm functions: 
   * `.i32`, `.i64`, `.f32` and `.f64`.
   */
  var returnTypes : [ WebAssembly.ValueType ] {
    return apiInvoke(wasmer_export_func_returns,
                     with: returnValueCount, on: self)
    {
      return WebAssembly.ValueType($0)
    }
  }
}
