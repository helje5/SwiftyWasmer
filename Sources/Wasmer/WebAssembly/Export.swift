//
//  Export.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public extension WebAssembly {
  
  /**
   * An `Export` object describes an entity exported by a `WebAssembly.Module`,
   * usually a function.
   *
   * Once an `Instance` is ready, its `exports` property can be used to access
   * the exports of a `Module`.
   */
  enum Export {
    
    case function(name           : String,
                  parameterTypes : [ WebAssembly.ValueType ],
                  returnTypes    : [ WebAssembly.ValueType ])
    
    case memory(WebAssembly.Memory)
    
    // TODO: Add the remaining types, but we need to reflect on them
    //       using descriptors I think? (i.e. globals)
  }
}
