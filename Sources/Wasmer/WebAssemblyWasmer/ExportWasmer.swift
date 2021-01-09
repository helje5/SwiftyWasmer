//
//  ExportWasmer.swift
//  Wasmer / WebAssemblyWasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension WebAssembly.Export {
  
  init?(_ export: UnsafeMutablePointer<wasmer_export_t>) {
    switch export.kind {
      case .function:
        guard let value = export.function else { return nil }
        self = .function(name           : export.name,
                         parameterTypes : value.parameterTypes,
                         returnTypes    : value.returnTypes)
        
      case .memory:
        guard let value = export.memory else { return nil }
        let memory = WebAssembly.Memory(handle: value, owned: false)
        self = .memory(memory)
        
      default:
        print("not handling this export kind yet:", export.kind, export)
        return nil
    }
  }
}
