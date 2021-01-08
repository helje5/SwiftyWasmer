//
//  ImportObjectIterPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_import_object_iter_t {

  func destroy() {
    wasmer_import_object_iter_destroy(self)
  }
  
  var isAtEnd: Bool {
    return wasmer_import_object_iter_at_end(self)
  }
  
  func forEach(execute: ( wasmer_import_t ) -> Void) {
    while !isAtEnd {
      var imp = wasmer_import_t()
      let rc  = wasmer_import_object_iter_next(self, &imp)
      wasmer_import_object_imports_destroy(&imp, 1);
      
      assert(rc == WASMER_OK)
      guard rc == WASMER_OK else { return }

      execute(imp)
    }
  }
}
