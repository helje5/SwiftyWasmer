//
//  Instance.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

public extension WebAssembly {
  
  /**
   * An `Instance` is an readymade object which allows the execution of
   * functions exported by a module.
   *
   * It is initialized with a `WebAssembly.Module` and an `ImportObject`.
   * Other convenience constructors are available.
   *
   * The main API it provides for users is the `Exports` object, which
   * can be accessed using `instance.exports`. The `Exports` object is
   * dynamically callable and can be used to invoke Wasm functions or
   * access the other available exports.
   *
   * Example:
   *
   *     let instance = try WebAssembly.Instance(sumData)
   *     let results  = try instance.exports.sum(.i32(7), .i32(8))
   *
   */
  final class Instance {

    public   let module       : Module
    public   let imports      : ImportObject

    private  let importHolder : Wasmer.ImportsHolder
    internal let handle       : UnsafeMutablePointer<wasmer_instance_t>
    
    /**
     * Initialize an `Instance` with a compiled `Module` and an optional
     * `ImportObject`.
     * If no imports are specified, the default is used (a default WASI setup).
     *
     * Example:
     *
     *     let module   = try WebAssembly.Module(wasmData)
     *     let instance = try WebAssembly.Instance(module)
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
     */
    public init(_ module: Module, _ imports: ImportObject = .init()) throws {
      let importHolder = Wasmer.ImportsHolder(importObject: imports)
      
      var ptr : UnsafeMutablePointer<wasmer_instance_t>? = nil
      let rc  : wasmer_result_t
      
      if let importObject = importHolder.importObject {
        rc = wasmer_module_import_instantiate(
          &ptr, module.handle,
          importObject
        )
      }
      else {
        rc = wasmer_module_instantiate(
          module.handle, &ptr,
          importHolder.rawImports.baseAddress,
          Int32(importHolder.rawImports.count)
        )
      }
      guard rc == WASMER_OK    else { throw WasmerError.last }
      guard let validPtr = ptr else {
        assertionFailure("Call returned w/ WASMER_OK, but got no handle?")
        throw WasmerError.internalInconsistency
      }
      
      self.module       = module
      self.imports      = imports
      self.importHolder = importHolder // do we have to stick to this?
      self.handle       = validPtr
      
      let contextPtr = Unmanaged.passUnretained(self)
      wasmer_instance_context_data_set(validPtr, contextPtr.toOpaque())
    }
    
    deinit {
      wasmer_instance_context_data_set(handle, nil)
      handle.destroy()
    }

    public var exports : Exports {
      return .init(instance: self)
    }
  }
}

public extension WebAssembly.Instance {
  
  convenience
  init(_ data: Data, _ imports: WebAssembly.ImportObject = .init()) throws {
    let module = try WebAssembly.compile(data)
    try self.init(module, imports)
  }
}
