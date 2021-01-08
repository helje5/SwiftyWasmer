//
//  ExportPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_export_t {
  
  var name : String {
    let nameBytes : wasmer_byte_array = wasmer_export_name(self)
    return String(cString: nameBytes.bytes)
  }
  
  var kind : Wasmer.ImportExportKind {
    guard let kind = Wasmer.ImportExportKind(wasmer_export_kind(self)) else {
      assertionFailure("could not map Wasmer kind!")
      return .global
    }
    return kind
  }
  
  var function : UnsafePointer<wasmer_export_func_t>? {
    return wasmer_export_to_func(self)
  }
  
  var memory : UnsafeMutablePointer<wasmer_memory_t>? {
    var ptr : UnsafeMutablePointer<wasmer_memory_t>? = nil
    wasmer_export_to_memory(self, &ptr)
    return ptr
  }
}
