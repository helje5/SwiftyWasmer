//
//  ByteArrayExt.swift
//  Wasmer / CExtensions
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

extension wasmer_byte_array {
  
  var count : Int { return Int(self.bytes_len) }
  
  func withUnsafeBytes<ResultType>
        (_ body: ( UnsafeRawBufferPointer ) throws -> ResultType)
        rethrows -> ResultType
  {
    let rbp = UnsafeRawBufferPointer(start: bytes, count: Int(bytes_len))
    return try body(rbp)
  }
  
  func copyToData() -> Data {
    withUnsafeBytes { rbp in
      Data(rbp)
    }
  }
}

extension wasmer_byte_array {
  
  /**
   * Note: This mallocs a copy of the UTF-8 characters in the string!
   */
  init(_ string: String) {
    let cstr = strdup(string)
    let clen = cstr != nil ? strlen(cstr!) : 0
    self.init(bytes     : unsafeBitCast(cstr, to: UnsafePointer<UInt8>.self),
              bytes_len : UInt32(clen))
  }
}

extension String {
  
  init?(_ byteArray: wasmer_byte_array) {
    guard byteArray.bytes_len > 0 else {
      self = ""
      return
    }
    let maybeString = byteArray.withUnsafeBytes { rbp in
      String(bytes: rbp, encoding: .utf8)
    }
    guard let string = maybeString else { return nil }
    self = string
  }
}
