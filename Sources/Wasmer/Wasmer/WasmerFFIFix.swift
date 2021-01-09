//
//  WasmerFFIFix.swift
//  Wasmer / Wasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

/// This only affects M1 machines w/ Wasmer 1.0.0
#if arch(arm64)
  /**
   Undefined symbols for architecture arm64:
     "_ffi_type_longdouble", referenced from:
         __ZN6libffi6middle5types4Type10longdouble17h63d3149b2a3e80d3E in libwasmer.a(libffi-b0805f500a4eac79.libffi.d6oiyy8u-cgu.0.rcgu.o)
   */
  @_cdecl("ffi_type_longdouble")
  func ffi_type_longdouble() -> Never {
    fatalError("ffi_type_longdouble is not available")
  }
#endif
