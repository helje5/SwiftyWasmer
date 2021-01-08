//
//  WASI.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

public enum WASI {
}

public extension WASI {
  
  struct Configuration {
    
    // Note: Actual configuration doesn't actually work in the Wasmer C API
    //       1.0.0 yet. Ugh.
    
    public var arguments   : [ String ]
    public var environment : [ String : String ]
    
    @inlinable
    public var isEmpty : Bool {
      return arguments.isEmpty && environment.isEmpty
    }
    
    @inlinable
    public init(arguments   : [ String ] = [],
                environment : [ String : String ] = [:])
    {
      self.arguments   = arguments
      self.environment = environment
    }
  }
}
