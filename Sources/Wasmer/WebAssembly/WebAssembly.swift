//
//  WebAssembly.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data

/**
 * The WebAssembly namespace.
 *
 * The namespace contains the actual types (`Module`, `Instance`, etc.),
 * but also provides the functions as suggested in the WebAssembly IDL.
 *
 * ### Examples
 *
 * Validation:
 *
 *     let ok = WebAssembly.validate(wasmData)
 *
 * Compilation:
 *
 *     let module = try WebAssembly.compile(wasmData)
 *
 * Instantiation:
 *
 *     let imports  =     WebAssembly.ImportObject(core: .wasi)
 *     let instance = try WebAssembly.instantiate (module, imports)
 *
 * Note that most types in SwiftyWasmer also include initializer which do the
 * same.
 */
public enum WebAssembly {
}

public extension WebAssembly {
  
  /**
   * Compile the given `Data` object containing `Wasm` code into a
   * `WebAssembly.Module`.
   *
   * Note: `WebAssembly.validate` can be used to validate Data prior
   *       compilation.
   *
   * - Parameters:
   *   - data:  A `Data` object containing WebAssembly binary code.
   * - Throws:  Usually a `WasmerError` when the data could not be compiled as
   *            Wasm.
   * - Returns: A `WebAssembly.Module` object representing the compiled code.
   */
  @inlinable
  static func compile(_ data: Data) throws -> Module {
    return try Module(data)
  }
  
  /**
   * Initialize an `Instance` with a compiled `Module` and an optional
   * `ImportObject`.
   * If no imports are specified, the default is used (a default WASI setup).
   *
   * Example:
   *
   *     let imports  =     WebAssembly.ImportObject(core: .wasi)
   *     let module   = try WebAssembly.compile     (wasmData)
   *     let instance = try WebAssembly.instantiate (module, imports)
   *
   *     let results  = try instance.exports.sum(.i32(7), .i32(8))
   *
   * - Parameters:
   *   - module:  The `WebAssembly.Module` to instantiate, a module has
   *              import requirements, exports and the actuall machine code.
   *   - imports: A `WebAssembly.ImportObject` which provides the environment
   *              the instance will run in. E.g. what ABI (none, WASI or
   *              Emscripten) is provided, or what Wasm functions the host
   *              wants to provide.
   * - Throws:    If something goes wrong an error is thrown, usually a
   *              `WasmerError`.
   * - Returns:   A `WebAssembly.Instance`, ready for execution.
   */
  @inlinable
  static func instantiate(_ module: Module, _ imports: ImportObject = .init())
                throws -> Instance
  {
    return try Instance(module, imports)
  }

  /**
   * Initialize an `Instance` with a compiled Wasm module contained in a `Data`
   * and an optional `ImportObject`.
   * If no imports are specified, the default is used (a default WASI setup).
   * 
   * Example:
   *
   *     let imports = WebAssembly.ImportObject(core: .wasi)
   *     let ( module, instance ) = 
   *             try WebAssembly.instantiate(wasmData, imports)
   *
   *     let results  = try instance.exports.sum(.i32(7), .i32(8))
   *
   * - Parameters:
   *   - data:    A `Data` object containing WebAssembly binary code.
   *   - imports: A `WebAssembly.ImportObject` which provides the environment
   *              the instance will run in. E.g. what ABI (none, WASI or
   *              Emscripten) is provided, or what Wasm functions the host
   *              wants to provide.
   * - Throws:    If something goes wrong an error is thrown, usually a
   *              `WasmerError`.
   * - Returns:   A tuple containing the `WebAssembly.Module` and the
   *              `WebAssembly.Instance`, ready for execution.
   */
  @inlinable
  static func instantiate(_ data: Data, _ imports: ImportObject = .init())
                throws -> ( module: Module, instance: Instance )
  {
    let module   = try compile(data)
    let instance = try instantiate(module, imports)
    return ( module: module, instance: instance )
  }
}
