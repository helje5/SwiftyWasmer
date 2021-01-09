//
//  Module.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer
import struct Foundation.Data
import struct Foundation.URL

public extension WebAssembly {
  
  /**
   * A compiled WebAssembly module.
   *
   * The module can be created from a `Data` containing compiled Wasm.
   *
   * Example:
   *
   *     let wasmFile = URL(fileURLWithPath: "sum.wasm")
   *     let module   = try Module(contentsOf: wasmFile)
   * 
   * Or using a `Data`:
   *
   *     let wasmFile = URL(fileURLWithPath: "sum.wasm")
   *     let wasmData = try Data(contentsOf: wasmFile)
   *     let module   = try WebAssembly.Module(wasmData)
   * 
   */
  final class Module {

    public   let url    : URL?
    internal let handle : UnsafeMutablePointer<wasmer_module_t>
    internal let owned  : Bool

    internal init(handle : UnsafeMutablePointer<wasmer_module_t>,
                  owned  : Bool,
                  url    : URL? = nil)
    {
      self.url    = url
      self.handle = handle
      self.owned  = owned
    }
    deinit {
      if owned { handle.destroy() }
    }
  }
}

public extension WebAssembly.Module {
  
  /**
   * Compile the given `Data` object containing `Wasm` code.
   *
   * Note: `WebAssembly.validate` can be used to validate Data prior
   *       compilation.
   *
   * - Parameters:
   *   - data: A `Data` object containing WebAssembly binary code.
   */
  convenience init(_ data: Data, url: URL? = nil) throws {
    let handle = try UnsafeMutablePointer<wasmer_module_t>(data: data)
    self.init(handle: handle, owned: true, url: url)
  }

  convenience init(contentsOf url: URL) throws {
    let data = try Data(contentsOf: url)
    try self.init(data, url: url)
  }
}
