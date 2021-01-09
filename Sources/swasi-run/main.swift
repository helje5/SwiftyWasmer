#!/usr/bin/swift sh

import Foundation
import Wasmer // AlwaysRightInstitute/SwiftyWasmer

/**
 * Usage:
 *
 *     wapm install -g cowsay
 *     swift run swasi-run \
 *       ~/.wasmer/globals/wapm_packages/_/cowsay\@0.2.0/target/wasm32-wasi/release/cowsay.wasm
 */

let args = CommandLine.arguments
guard args.count > 1 else {
  let tool = args.first.flatMap(URL.init(fileURLWithPath:))?.lastPathComponent
  print(
    """
    Usage: \(tool ?? "swasi-run") <wasm-file>
    
      The tool runs the Wasm file passed in in a WASI environment.
      No arguments or environment are being passed on (yet).
    
    """
  )
  exit(1)
}

let fileURL  = URL(fileURLWithPath: args[1])
let data     : Data
let imports  = WebAssembly.ImportObject.init(core: .wasi)
let module   : WebAssembly.Module
let instance : WebAssembly.Instance

do {
  data = try Data(contentsOf: fileURL)
}
catch {
  fputs("Failed to load file:\n  \(args[1])\n\n", stderr)
  fputs("Error:\n  \(error)\n\n", stderr)
  exit(2)
}

do {
  module = try WebAssembly.Module(data)
}
catch {
  fputs("Failed to compile file:\n  \(args[1])\n\n", stderr)
  fputs("Error:\n  \(error)\n\n", stderr)
  exit(10)
}

do {
  instance = try WebAssembly.Instance(module, imports)
}
catch WasmerError.importError(let reason) {
  fputs("Failed to instantiate module:\n  \(args[1])\n\n", stderr)
  fputs("Import Error:\n  \(reason)\n\n", stderr)
  exit(11)
}
catch {
  fputs("Failed to instantiate module:\n  \(args[1])\n\n", stderr)
  fputs("Error:\n  \(error)\n\n", stderr)
  exit(12)
}


// MARK: - Run

do {
  let results = try instance.exports._start()
  if !results.isEmpty {
    print("\nResults:", results)
  }
  exit(0)
}
catch {
  fputs("Failed to start the module:\n  \(args[1])\n\n", stderr)
  fputs("Error:\n  \(error)\n\n", stderr)
  exit(20)
}
