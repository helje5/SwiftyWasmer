//
//  ImportObject.swift
//  Wasmer / WebAssembly
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import struct Foundation.Data

public extension WebAssembly {
  
  /**
   * The import object is used to setup the values provided to a module
   * when it is instantiated.
   *
   * It can be an actual Wasmer import object like WASI or (not yet) Emscripten,
   * or it can  be a set of plain import declarations,
   * or a combination of those.
   *
   * By default a default WASI configuration is used, with no additional
   * imports.
   * 
   * Example:
   *
   *     let imports = WebAssembly.ImportObject(core: .wasi)
   *     imports[name: "memory"]        = try WebAssembly.Memory()
   *     imports[name: "__memory_base"] = WebAssembly.Global(.i32(1024))
   *
   *     let instance = try WebAssembly.Instance(wasmData, imports)
   *
   */
  final class ImportObject {
    
    public enum Core {
      case plain
      case wasi(WASI.Configuration)
      // TODO: emscripten
      
      public static let wasi = Core.wasi(.init())
    }
    
    public struct QualifiedName: Hashable {
      
      public let moduleName : String
      public let importName : String
    }
    
    public enum Import {
      
      case function(argumentTypes : [ ValueType ],
                    returnTypes   : [ ValueType ],
                    cfunc         : @convention(c)
                                    ( UnsafeMutableRawPointer? ) -> Void)
      
      case memory(Memory)
      
      case global(Global)
      
      // TODO: other things :-)
    }
    
    public var defaultModule : String
    public var core          : Core
    public var imports       = [ QualifiedName : Import ]()
    
    @inlinable
    public var isEmpty : Bool { return imports.isEmpty }
    @inlinable
    public var count   : Int  { return imports.count }
    
    @inlinable
    public init(defaultModule : String = "zz",
                core          : Core = .wasi)
    {
      self.defaultModule = defaultModule
      self.core          = core
    }
  }
}

public extension WebAssembly.ImportObject {
  
  @inlinable
  subscript(name name: String) -> WebAssembly.Memory? {
    set { self[module: defaultModule, name: name] = newValue }
    get { return self[module: defaultModule, name: name] }
  }
  @inlinable
  subscript(name name: String) -> WebAssembly.Global? {
    set { self[module: defaultModule, name: name] = newValue }
    get { return self[module: defaultModule, name: name] }
  }

  subscript(module module: String, name name: String) -> WebAssembly.Memory? {
    set {
      let qname = QualifiedName(moduleName: module, importName: name)
      if let value = newValue {
        imports[qname] = .memory(value)
      }
      else {
        guard case .memory = imports[qname] else { return }
        imports.removeValue(forKey: qname)
      }
    }
    get {
      let qname = QualifiedName(moduleName: module, importName: name)
      guard case .memory(let value) = imports[qname] else { return nil }
      return value
    }
  }
  
  subscript(module module: String, name name: String) -> WebAssembly.Global? {
    set {
      let qname = QualifiedName(moduleName: module, importName: name)
      if let value = newValue {
        imports[qname] = .global(value)
      }
      else {
        guard case .global = imports[qname] else { return }
        imports.removeValue(forKey: qname)
      }
    }
    get {
      let qname = QualifiedName(moduleName: module, importName: name)
      guard case .global(let value) = imports[qname] else { return nil }
      return value
    }
  }
}

extension WebAssembly.ImportObject: CustomStringConvertible {
  
  public var description: String {
    guard !isEmpty else { return "<Imports: empty>" }
    var ms = "<Imports:"; defer { ms += ">" }
    for ( qname, imp ) in imports {
      ms += " \(qname.moduleName).\(qname.importName)="
      ms += "\(imp)"
    }
    return ms
  }
}
