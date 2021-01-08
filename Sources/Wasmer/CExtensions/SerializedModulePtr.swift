//
//  SerializedModulePtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_serialized_module_t {
  
  func destroy() {
    wasmer_serialized_module_destroy(self)
  }
  
  init(data: Data) throws {
    var ptr : Self? = nil
        
    let rc = data.withMutableUnsignedBytes { typed in
      return wasmer_serialized_module_from_bytes(
               &ptr, typed.baseAddress, UInt32(typed.count))
    }
    
    guard rc == WASMER_OK    else { throw WasmerError.last }
    guard let validPtr = ptr else {
      assertionFailure("Call returned w/ WASMER_OK, but got no handle?")
      throw WasmerError.internalInconsistency
    }
    
    self = validPtr
  }
  
  func asData() -> Data {
    wasmer_serialized_module_bytes(self).copyToData()
  }
}
