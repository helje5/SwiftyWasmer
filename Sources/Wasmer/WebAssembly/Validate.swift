//
//  Validate.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

public extension WebAssembly {
  
  /**
   * Validate whether the given `Data` object contains a valid `Wasm` module.
   *
   * - Parameters:
   *   - data: A `Data` object containing WebAssembly binary code.
   * - Returns: `true` if valid, `false` otherwise
   */
  static func validate(_ data: Data) -> Bool {
    return data.withUnsignedBytes { typed in
      return wasmer_validate(typed.baseAddress, UInt32(typed.count))
    }
  }
  
  /**
   * Validate whether the given byte array contains a valid `Wasm` module.
   *
   * - Parameters:
   *   - data: A `Data` object containing WebAssembly binary code.
   * - Returns: `true` if valid, `false` otherwise
   */
  static func validate(_ data: [ UInt8 ]) -> Bool {
    return data.withUnsignedBytes { typed in
      return wasmer_validate(typed.baseAddress, UInt32(typed.count))
    }
  }
}
