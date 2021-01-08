//
//  MemoryPtr.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension UnsafePointer where Pointee == wasmer_memory_t {
  
  var count: Int {
    return Int(wasmer_memory_data_length(self))
  }
  
  var pageCount: Int {
    // page size seems to be 64KB
    return Int(wasmer_memory_length(self))
  }
  
  var bytes : UnsafeMutablePointer<UInt8>? {
    return wasmer_memory_data(self)
  }
}

extension UnsafeMutablePointer where Pointee == wasmer_memory_t {
  
  func destroy() {
    wasmer_memory_destroy(self)
  }

  func grow(_ delta: Int) throws {
    let rc = wasmer_memory_grow(self, UInt32(delta))
    guard rc == WASMER_OK else { throw WasmerError.last }
  }

  var count     : Int { return UnsafePointer(self).count     }
  var pageCount : Int { return UnsafePointer(self).pageCount }
  
  static func allocate(minimum: Int = 0, maximumPages: Int? = 256)
                throws -> Self
  {
    // TBD: so, is minimum bytes or pages?
    var ptr : UnsafeMutablePointer<wasmer_memory_t>? = nil
    let rc = wasmer_memory_new(
      &ptr, .init(minimum: minimum, maximumPages: maximumPages)
    )
    assert(rc == WASMER_OK)
    guard rc == WASMER_OK    else { throw WasmerError.last }
    guard let validPtr = ptr else { throw WasmerError.last }
    return validPtr
  }
}

extension wasmer_limits_t {
  init(minimum: Int = 0, maximumPages: Int? = 256) {
    self.init(min: UInt32(minimum),
              max: .init(has_some: maximumPages != nil,
                         some: UInt32(maximumPages ?? 0)))
  }
}
