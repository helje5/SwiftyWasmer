//
//  GlobalPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_global_t {
  
  func destroy() {
    wasmer_global_destroy(self)
  }
  
  var rawValue : wasmer_value_t {
    nonmutating set { wasmer_global_set(self, newValue) }
    get { return wasmer_global_get(self) }
  }
  
  /**
   * Allocates a new global w/ the given setup.
   */
  init?(_ rawValue: wasmer_value_t, isMutable: Bool = false) {
    guard let ptr = wasmer_global_new(rawValue, isMutable) else { return nil}
    self = ptr
  }
}
