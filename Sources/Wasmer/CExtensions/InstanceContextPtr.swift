//
//  InstanceContextPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafeMutablePointer where Pointee == wasmer_instance_context_t {

  var contextData : UnsafeMutableRawPointer? {
    return wasmer_instance_context_data_get(self)
  }
  
  subscript(memory idx: Int) -> WebAssembly.Memory? {
    guard let mem = wasmer_instance_context_memory(self, UInt32(idx)) else {
      return nil
    }
    
    // Yeah, I know. All not great.
    let mp = UnsafeMutablePointer<wasmer_memory_t>(mutating: mem)
    return WebAssembly.Memory(handle: mp, owned: false)
  }
}
