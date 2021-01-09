#  Swift Runtime API for Wasmer

A Swift API for the 
[Wasmer](https://wasmer.io) 
[WebAssembly](https://webassembly.org) 
Runtime.

The usual approach is to `import Wasmer`, and then access the API
available in the `WebAssembly` namespace.

What does it look like? Like this:

```swift
import Wasmer

// Just load a file into memory
let wasmFile = URL(fileURLWithPath: "sum.wasm")
let wasmData = try Data(contentsOf: wasmFile)

// Compile the Data into a module, and instantiate that
let module   = try WebAssembly.Module  (wasmData)
let instance = try WebAssembly.Instance(module)

// Run a function exported by the Module
let results = try instance.exports.sum(.i32(7), .i32(8))
```

### Links

- [Wasmer](https://wasmer.io)
  - [Documentation](https://docs.wasmer.io)
- [WebAssembly](https://webassembly.org)
  - [Developers Guide](https://webassembly.org/getting-started/developers-guide/)

### Who

**SwiftyWasmer** is brought to you by
the
[Always Right Institute](https://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like 
[feedback](https://twitter.com/ar_institute), 
GitHub stars, 
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
