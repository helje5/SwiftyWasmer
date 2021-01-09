//
//  WasmerImportExportKind.swift
//  Wasmer / Wasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension Wasmer {
  
  enum ImportExportKind: UInt8 {
    
    case function, global, memory, table
          
    init?(_ value: UInt32) {
      switch value {
        case WASM_FUNCTION.rawValue: self = .function
        case WASM_GLOBAL  .rawValue: self = .global
        case WASM_MEMORY  .rawValue: self = .memory
        case WASM_TABLE   .rawValue: self = .table
        default:
          assertionFailure("Unexpected import/export kind \(value)!")
          return nil
      }
    }
  }
}
