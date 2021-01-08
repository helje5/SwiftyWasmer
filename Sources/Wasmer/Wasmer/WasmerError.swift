//
//  WasmerError.swift
//  Wasmer / Wasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

public enum WasmerError: Swift.Error {

  case runtime    (reason: String)
  case importError(reason: String)
  case other      (reason: String)
  
  case noErrorString
  case internalInconsistency
  
  public var reason : String {
    switch self {
      case .runtime    (let reason) : return reason
      case .importError(let reason) : return reason
      case .other      (let reason) : return reason
      case .internalInconsistency   : return "Internal API inconsistency"
      case .noErrorString           : return "API call failed, error missing"
    }
  }
  
  static var last : WasmerError {
    var lastError : String? {
      // TBD: what is the thread safety of this?!
      let len = wasmer_last_error_length()
      guard len > 0 else { return nil }
      assert(len < 100_000)
      let cstr = UnsafeMutablePointer<Int8>.allocate(capacity: Int(len))
      wasmer_last_error_message(cstr, len)
      return String(cString: cstr)
    }
    guard let reason = lastError else { return .noErrorString }
    
    enum MagicCodes {
      // - RuntimeError: Parameters of type [I64, I32] did not match signature [I32, I32] -> [I32]
      static let runtimeErrorPrefix = "RuntimeError: "
      
      // - Error while importing \"wasi_snapshot_preview1\".\"fd_write\": unknown import. Expected Function(FunctionType { params: [I32, I32, I32, I32], results: [I32] })
      static let importErrorPrefix  = "Error while importing "
    }
    
    if reason.hasPrefix(MagicCodes.runtimeErrorPrefix) {
      return .runtime(reason:
        String(reason.dropFirst(MagicCodes.runtimeErrorPrefix.count)))
    }

    if reason.hasPrefix(MagicCodes.importErrorPrefix) {
      // TBD: we could try to parse more details.
      return .importError(reason: reason) // no cutoff here
    }

    return .other(reason: reason)
  }
}
