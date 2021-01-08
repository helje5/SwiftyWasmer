//
//  Memory.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

public extension WebAssembly {
  
  /**
   * This calls represents the memory attached to a Wasm instance.
   * Memory in WebAssembly is just an array of bytes, which can even
   * grow.
   * 
   * The memory is organized in pages of 64KB each.
   *
   * Example Setup:
   *
   *     let imports = WebAssembly.ImportObject()
   *     imports[name: "memory"]        = try WebAssembly.Memory()
   *     imports[name: "__memory_base"] = WebAssembly.Global(.i32(1024))
   *
   */
  final class Memory {
    
    internal let handle : UnsafeMutablePointer<wasmer_memory_t>
    internal let owned  : Bool

    internal init(handle : UnsafeMutablePointer<wasmer_memory_t>,
                  owned  : Bool)
    {
      self.handle = handle
      self.owned  = owned
    }
    deinit {
      if owned { handle.destroy() }
    }
    
    /// Returns the size of the memory in bytes
    public var count     : Int { return handle.count     }
    
    /// Returns the size of the memory in 64KB pages
    public var pageCount : Int { return handle.pageCount }
  }
}

public extension WebAssembly.Memory {
  
  /**
   * Initialize new Wasmer memory with a set of constraints.
   * 
   * The memory is organized in pages of 64KB each.
   *
   * Example Setup:
   *
   *     let imports = WebAssembly.ImportObject()
   *     imports[name: "memory"] = 
   *       try WebAssembly.Memory(minimum: 256, maximumPages: 256)
   *     imports[name: "__memory_base"] = WebAssembly.Global(.i32(1024))
   *
   */
  convenience init(minimum: Int = 256, maximumPages: Int? = 256) throws {
    let handle = try UnsafeMutablePointer<wasmer_memory_t>
                       .allocate(minimum: minimum, maximumPages: maximumPages)
    self.init(handle: handle, owned: true)
  }
}

extension WebAssembly.Memory: CustomStringConvertible {
  
  public var description: String {
    return "<Memory: \(count) bytes (\(pageCount) pages)>"
  }
}
