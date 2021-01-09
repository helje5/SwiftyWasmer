//
//  Exports.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

public extension WebAssembly {
  
  /**
   * An `ExportValue` is a helper object which represents an actual `Export`
   * value in an `Instance`. For example an exported function.
   *
   * The `ExportValue` is retrieved from the `Exports` object, for example:
   *
   *     let sumFunction = instance.exports.sum
   *
   * The `ExportValue` is a Swift `dynamicCallable`, which means it can be
   * directly invoked:
   *
   *     let results = try sumFunction(.i32(7), .i32(8))
   *
   * If the provided signature doesn't match, an Error will be thrown.
   */
  @dynamicCallable
  struct ExportValue {
    
    public enum InvocationError: Swift.Error {
      case exportNotFound(String)
      case memoryCannotBeInvoked
      case notImplemented
      case missingData
    }

    public let instance : WebAssembly.Instance
    public let name     : String
    
    fileprivate let rawExport : UnsafeMutablePointer<wasmer_export_t>?
    
    /**
     * Returns `true` if the export with the used name is available.
     */
    public var isAvailable : Bool {
      return rawExport != nil
    }
    
    public func dynamicallyCall(withArguments args: [ WebAssembly.Value ])
                  throws -> [ WebAssembly.Value ]
    {
      guard let rawExport = rawExport else {
        throw InvocationError.exportNotFound(name)
      }
      
      switch rawExport.kind {
        case .function:
          guard let function = rawExport.function else {
            throw InvocationError.missingData
          }
          
          // Note: We do have the func signature here and could coerce if we
          //       wanted to. Note sure it makes sense.
          let rawArgs = args.makeRawValueArray()
          defer { rawArgs.deallocate() }
          
          let resultBuffer = UnsafeMutableBufferPointer<wasmer_value_t>
                .allocate(capacity: function.returnValueCount)
          defer { resultBuffer.deallocate() }
          
          let rc = wasmer_export_func_call(
            function,
            rawArgs     .baseAddress, UInt32(rawArgs.count),
            resultBuffer.baseAddress, UInt32(resultBuffer.count)
          )
          guard rc == WASMER_OK else { throw WasmerError.last }
          
          return resultBuffer.map { WebAssembly.Value(wasmerValue: $0) }
        
        case .memory:
          // FIXME: we could provide some access, e.g. by index etc
          throw InvocationError.memoryCannotBeInvoked
          
        default:
          throw InvocationError.notImplemented
      }
    }
  }
  
  /**
   * `WebAssembly.Exports` represents all the exports for the `Instance`.
   *
   * The `Exports` object is retrieved from a `WebAssembly.Instance` using
   * the `exports` property.
   *
   * Besides providing explicit functions to access the exports table,
   * `Exports` is a Swift dynamicMemberLookup. Which means regular dot
   * syntax can be used to access the members, for example:
   *
   *     let sumFunction = instance.exports.sum
   *
   */
  @dynamicMemberLookup
  struct Exports {
    
    let instance : WebAssembly.Instance
    
    init(instance: WebAssembly.Instance) {
      self.instance = instance
    }
    
    /**
     * Returns the `ExportValue` for a given name. If the export doesn't
     * exist, the return value will return `false` in `isAvailable`,
     * or throw an `InvocationError` when it is called.
     *
     * Example:
     *
     *     try instance.exports.sum(.i32(7), .i32(8))
     *
     */
    public subscript(dynamicMember name: String) -> ExportValue {
      return ExportValue(instance: instance, name: name,
                         rawExport: self[rawExport: name])
    }

    /**
     * Returns the number of exports which are available in the exports table
     * of the `Instance`.
     */
    public var count: Int {
      return instance.handle.exportTable?.count ?? 0
    }

    /**
     * Returns an `Export` by index in the export table.
     */
    public subscript(index: Int) -> Export? {
      guard let table  = instance.handle.exportTable else { return nil }
      guard let export = table[index]                else { return nil }
      guard let value  = WebAssembly.Export(export)  else { return nil }
      return value
    }

    public subscript(rawExport name: String)
           -> UnsafeMutablePointer<wasmer_export_t>?
    {
      guard let table = instance.handle.exportTable else { return nil }
      for i in 0..<table.count {
        guard let export = table[i] else { continue }
        if export.name == name { return export }
      }
      return nil
    }
    
    public subscript(export name: String) -> Export? {
      guard let table = instance.handle.exportTable else { return nil }
      for i in 0..<table.count {
        guard let export = table[i] else { continue }
        if export.name == name {
          guard let value = WebAssembly.Export(export) else { continue }
          return value
        }
      }
      return nil
    }

    /**
     * Returns all exports as a dictionary.
     */
    public var exports : [ String : WebAssembly.Export ] {
      guard let table = instance.handle.exportTable else { return [:] }
      var exports = [ String : WebAssembly.Export ]()
      table.forEach { export in
        guard let value = WebAssembly.Export(export) else {
          print("not handling export yet:", export)
          return
        }
        
        let name = export.name
        assert(exports[name] == nil)
        exports[name] = value
      }
      return exports
    }
  }
}

extension WebAssembly.Exports: Sequence {
  
  @inlinable
  public func makeIterator() -> Dictionary<String, WebAssembly.Export>.Iterator
  {
    return exports.makeIterator()
  }

  public var underestimatedCount: Int {
    return instance.handle.exportTable?.count ?? 0
  }
}
