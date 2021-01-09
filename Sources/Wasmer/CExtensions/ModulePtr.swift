//
//  ModulePtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_module_t {
  
  func destroy() {
    wasmer_module_destroy(self)
  }

  /**
   * Compile the given `Data` object containing `Wasm` code.
   *
   * Note: `WebAssembly.validate` can be used to validate Data prior
   *       compilation.
   *
   * - Parameters:
   *   - data: A `Data` object containing WebAssembly binary code.
   */
  init(data: Data) throws {
    var ptr : UnsafeMutablePointer<wasmer_module_t>? = nil
    
    let rc = data.withMutableUnsignedBytes { typed in
      return wasmer_compile(&ptr, typed.baseAddress, UInt32(typed.count))
    }
    guard rc == WASMER_OK    else { throw WasmerError.last }
    guard let validPtr = ptr else {
      assertionFailure("Call returned w/ WASMER_OK, but got no handle?")
      throw WasmerError.internalInconsistency
    }
        
    self = validPtr
  }
  
  /**
   * Deserialize a module from the given serialized module pointer.
   */
  init(from serializedModule: UnsafeMutablePointer<wasmer_serialized_module_t>)
    throws
  {
    var ptr : UnsafeMutablePointer<wasmer_module_t>? = nil

    let rc = wasmer_module_deserialize(&ptr, serializedModule)
    guard rc == WASMER_OK    else { throw WasmerError.last }
    guard let validPtr = ptr else {
      assertionFailure("Call returned w/ WASMER_OK, but got no handle?")
      throw WasmerError.internalInconsistency
    }
        
    self = validPtr
  }

  /**
   * Deserialize a module from the given serialized module `Data`.
   */
  init(from serializedData: Data) throws {
    let serializedModule =
      try UnsafeMutablePointer<wasmer_serialized_module_t>(data: serializedData)
    try self.init(from: serializedModule)
  }

  /**
   * Serialize module to a `Data` object.
   */
  func serialize() throws -> Data {
    var ptr : UnsafeMutablePointer<wasmer_serialized_module_t>? = nil
    let rc = wasmer_module_serialize(&ptr, self)
    
    guard rc == WASMER_OK    else { throw WasmerError.last }
    guard let validPtr = ptr else {
      assertionFailure("Call returned w/ WASMER_OK, but got no handle?")
      throw WasmerError.internalInconsistency
    }
    
    defer { validPtr.destroy() }
    
    return validPtr.asData()
  }
}
