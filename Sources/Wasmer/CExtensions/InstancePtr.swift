//
//  InstancePtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_instance_t {
  
  func destroy() {
    wasmer_instance_destroy(self)
  }

  var exportTable : UnsafeMutablePointer<wasmer_exports_t>? {
    var exports : UnsafeMutablePointer<wasmer_exports_t>? = nil
    wasmer_instance_exports(self, &exports);
    return exports
  }

  var instanceContext : UnsafePointer<wasmer_instance_context_t>? {
    return wasmer_instance_context_get(self)
  }
}
