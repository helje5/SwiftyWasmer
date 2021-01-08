//
//  CAPIUtilities.swift
//  Wasmer / Utilities
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data
import CWasmer

protocol ClearInit {
  static func clear() -> Self
}

extension UInt32: ClearInit {
  static func clear() -> Self { return 0 }
}

#if false // crashes swiftc as usual
extension Optional : ClearInit
    where Wrapped == UnsafeMutablePointer<wasmer_memory_t>
{
  static func clear() -> Self { return .none }
}
#endif

func apiInvoke<T, VT>(_ apifunc: ( T, UnsafeMutablePointer<VT> )
                                   -> wasmer_result_t,
                      on object: T)
     -> VT
     where VT: ClearInit
{
  var value = VT.clear()
  let rc = apifunc(object, &value)
  assert(rc == WASMER_OK)
  return value
}

#if false // to throw or not
func apiInvoke<T, VT>(_ apifunc: ( T, UnsafeMutablePointer<VT> )
                                   -> wasmer_result_t,
                      on object: T)
       throws -> VT
       where VT: ClearInit
{
  var value = VT.clear()
  let rc = apifunc(object, &value)
  assert(rc == WASMER_OK)
  guard rc == WASMER_OK else { throw WasmerError.last }
  return value
}
#endif

/**
 * Invoke an API func which fills an array buffer.
 *
 * This function allocates the necessary buffer. The caller needs to deallocate
 * it.
 */
func apiInvoke<T, VT>(_  apifunc : ( T, UnsafeMutablePointer<VT>, UInt32 )
                                     -> wasmer_result_t,
                      with count : Int,
                      on  object : T)
       throws -> UnsafeMutableBufferPointer<VT>?
{
  assert(count >= 0)
  guard count > 0 else { return nil}

  let buf = UnsafeMutableBufferPointer<VT>.allocate(capacity: count)

  let rc = apifunc(object, buf.baseAddress!, UInt32(count))
  guard rc == WASMER_OK else { throw WasmerError.last }
  return buf
}

/**
 * Invoke an API func which fills an array buffer.
 */
func apiInvoke<T, VT, RT>(_  apifunc : ( T, UnsafeMutablePointer<VT>, UInt32 )
                                     -> wasmer_result_t,
                      with count : Int,
                      on  object : T,
                      map : ( VT ) -> RT )
     -> [ RT ]
{
  guard let buf = try? apiInvoke(apifunc, with: count, on: object) else {
    return []
  }
  defer { buf.deallocate() }
  return buf.map(map)
}


// MARK: - Extension to avoid UInt8 casts all over

extension Data {

  /// Note: CAREFUL WITH THIS
  func withMutableUnsignedBytes<ResultType>
    (_ body: ( UnsafeMutableBufferPointer<UInt8> ) throws -> ResultType)
    rethrows -> ResultType
  {
    // TBD:
    // This is non-sense to please the API. We should probably just cast
    // instead.
    var dataCopy = self
    
    return try dataCopy.withUnsafeMutableBytes {
      ( rbp : UnsafeMutableRawBufferPointer ) -> ResultType in
      let typed = rbp.bindMemory(to: UInt8.self)
      return try body(typed)
    }
  }

  func withUnsignedBytes<ResultType>
    (_ body: ( UnsafeBufferPointer<UInt8> ) throws -> ResultType)
    rethrows -> ResultType
  {
    return try withUnsafeBytes {
      ( rbp : UnsafeRawBufferPointer ) -> ResultType in
      let typed = rbp.bindMemory(to: UInt8.self)
      return try body(typed)
    }
  }
}

extension Array where Element == UInt8 {
  
  func withUnsignedBytes<ResultType>
    (_ body: ( UnsafeBufferPointer<UInt8> ) throws -> ResultType)
    rethrows -> ResultType
  {
    return try withUnsafeBytes {
      ( rbp : UnsafeRawBufferPointer ) -> ResultType in
      let typed = rbp.bindMemory(to: UInt8.self)
      return try body(typed)
    }
  }
}
