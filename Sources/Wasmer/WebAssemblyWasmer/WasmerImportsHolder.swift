//
//  WasmerImportsHolder.swift
//  Wasmer / WebAssemblyWasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

extension Wasmer {

  /**
   * This is used to maintain the memory allocated for the import
   * declarations.
   */
  final class ImportsHolder {
    // TBD: I'm not quite sure whether we need to hold on to this after the
    //      initialize
    
    var importObject        : UnsafeMutablePointer<wasmer_import_object_t>?
    var rawImports          : UnsafeMutableBufferPointer<wasmer_import_t>
    var plainPointersToFree = [ UnsafeRawPointer ]()
    var impFuncsToDestroy   = [ UnsafeMutablePointer<wasmer_import_func_t> ]()
    
    deinit {
      importObject?.destroy()
      rawImports.deallocate()
      for ptr in impFuncsToDestroy {
        wasmer_import_func_destroy(ptr)
      }
      for ptr in plainPointersToFree {
        ptr.deallocate()
      }
    }
    
    private func addPlain(_ ptrs: UnsafeRawPointer?...) {
      for ptr in ptrs {
        guard let ptr = ptr else { continue }
        plainPointersToFree.append(ptr)
      }
    }

    init(importObject: WebAssembly.ImportObject) {
      // FIXME: split up, this is getting way too big
      
      rawImports = UnsafeMutableBufferPointer<wasmer_import_t>
                     .allocate(capacity: importObject.imports.count)
      
      switch importObject.core {
        case .wasi(let wasi):
          if wasi.isEmpty {
            self.importObject =
              UnsafeMutablePointer<wasmer_import_object_t>.defaultWASI
          }
          else { // TODO: all stuff
            // 'not yet implemented: wasmer_wasi_generate_import_object:
            // blocked on global store',
            // lib/c-api/src/deprecated/import/wasi.rs:74:5
            
            let rawArgs = UnsafeMutableBufferPointer<wasmer_byte_array>
                            .allocate(capacity: wasi.arguments.count)
            let rawEnv  = UnsafeMutableBufferPointer<wasmer_byte_array>
                            .allocate(capacity: wasi.environment.count)
            addPlain(rawArgs.baseAddress, rawEnv.baseAddress)
            
            for ( idx, arg ) in wasi.arguments.enumerated() {
              let raw = wasmer_byte_array(arg)
              rawArgs[idx] = raw
              addPlain(raw.bytes)
            }
            for ( idx, ( key, value ) ) in wasi.environment.enumerated() {
              let envline = "\(key)=\(value)"
              let raw = wasmer_byte_array(envline)
              rawEnv[idx] = raw
              addPlain(raw.bytes)
            }
            
            #if true
            // aborts with:
            // not yet implemented: Arg and env parsing need to be done here;
            // this logic already exists and it's important to get it right,
            // so we should probably reorganize code to make it easier to do
            // the right thing
            self.importObject = wasmer_wasi_generate_import_object_for_version(
              1,
              nil, 0,
              nil, 0,
              nil, 0, // preopened_files (wasmer_byte_array)
              nil, 0  // mapped_dirs     (wasmer_wasi_map_dir_entry_t)
            )
            #else
            self.importObject = wasmer_wasi_generate_import_object(
              rawArgs.baseAddress, UInt32(rawArgs.count),
              rawEnv .baseAddress, UInt32(rawEnv .count),
              nil, 0, // preopened_files (wasmer_byte_array)
              nil, 0  // mapped_dirs     (wasmer_wasi_map_dir_entry_t)
            )
            #endif
          }
        case .plain:
          break
      }
      
      var slot = 0
      for ( qname, imp ) in importObject.imports {
        // TBD: we could unique the module names and safe some memory
        let modname = wasmer_byte_array(qname.moduleName)
        let impname = wasmer_byte_array(qname.importName)
        addPlain(modname.bytes, impname.bytes)

        rawImports[slot].module_name = modname
        rawImports[slot].import_name = impname

        switch imp {
        
          // TODO: add more imports
        
          case .function(let argumentTypes, let returnTypes, let cfunc):
            let rawArgTypes = argumentTypes.makeRawValueArray()
            let rawRetTypes = returnTypes  .makeRawValueArray()
            addPlain(rawArgTypes.baseAddress, rawRetTypes.baseAddress)
            
            let value = wasmer_import_func_new(
              cfunc,
              rawArgTypes.baseAddress, UInt32(rawArgTypes.count),
              rawRetTypes.baseAddress, UInt32(rawRetTypes.count)
            )
            assert(value != nil)
            guard let validPtr = value else { continue }
            impFuncsToDestroy.append(validPtr)
            
            rawImports[slot].tag        = WASM_FUNCTION.rawValue
            rawImports[slot].value.func = UnsafePointer(validPtr)
            slot += 1
            
          case .memory(let memory):
            rawImports[slot].tag = WASM_MEMORY.rawValue
            rawImports[slot].value.memory = UnsafePointer(memory.handle)
            slot += 1

          case .global(let global):
            rawImports[slot].tag = WASM_GLOBAL.rawValue
            rawImports[slot].value.global = UnsafePointer(global.handle)
            slot += 1
        }
      }
      
      // If we have both, import object and imports, we need to merge them
      // together.
      if let importObject = self.importObject {
        do {
          try importObject.extend(with: UnsafeBufferPointer(rawImports))
        }
        catch {
          print("failed to extend import object?:", error)
          assertionFailure("failed to extend import object: \(error)")
        }
      }
    }
  }
}
