//
//  ImportObjectPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_import_object_t {
  
  init() {
    self = wasmer_import_object_new()
  }
  
  static var defaultWASI : UnsafeMutablePointer<wasmer_import_object_t> {
    return wasmer_wasi_generate_default_import_object()
  }
  
  func destroy() {
    wasmer_import_object_destroy(self)
  }
  
  func extend(with imports: UnsafeBufferPointer<wasmer_import_t>) throws {
    let rc = wasmer_import_object_extend(
               self, imports.baseAddress, UInt32(imports.count))
    guard rc == WASMER_OK else { throw WasmerError.last }
  }
  
  func iterateFunctions() -> UnsafeMutablePointer<wasmer_import_object_iter_t> {
    return wasmer_import_object_iterate_functions(self)
  }
}
