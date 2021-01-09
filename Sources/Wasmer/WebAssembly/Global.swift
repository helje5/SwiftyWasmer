//
//  Global.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

public extension WebAssembly {
  
  /**
   * Globals are global values accessible to the inner instance.
   * They are references, because those can be set.
   */
  final class Global {
    
    internal let handle : UnsafeMutablePointer<wasmer_global_t>
    internal let owned  : Bool

    internal init(handle : UnsafeMutablePointer<wasmer_global_t>,
                  owned  : Bool)
    {
      self.handle = handle
      self.owned  = owned
    }
    deinit {
      if owned { handle.destroy() }
    }
    
    /**
     * Get or set the value associated with the Global.
     */
    public var value : WebAssembly.Value {
      set { handle.rawValue = newValue.wasmerValue }
      get { return WebAssembly.Value(wasmerValue: handle.rawValue) }
    }
  }
}

public extension WebAssembly.Global {
  
  convenience init?(_ value: WebAssembly.Value, isMutable: Bool = false) {
    guard let handle =
      UnsafeMutablePointer<wasmer_global_t>(value.wasmerValue,
                                            isMutable: isMutable) else
    {
      return nil
    }
    self.init(handle: handle, owned: true)
  }
}
