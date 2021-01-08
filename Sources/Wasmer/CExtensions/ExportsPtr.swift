//
//  exports.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_exports_t {
  
  var count : Int {
    Int(wasmer_exports_len(self))
  }
  
  func forEach(execute: (UnsafeMutablePointer<wasmer_export_t>) -> Void) {
    for i in 0..<count {
      guard let export = wasmer_exports_get(self, Int32(i)) else {
        assertionFailure("nil export?!")
        continue
      }
      execute(export)
    }
  }
  
  subscript(index: Int) -> UnsafeMutablePointer<wasmer_export_t>? {
    return wasmer_exports_get(self, Int32(index))
  }
  
  func destroy() {
    wasmer_exports_destroy(self)
  }
}
