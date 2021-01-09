# SwiftyWasmer

A Swift API for the 
[Wasmer](https://wasmer.io) 
[WebAssembly](https://webassembly.org) 
Runtime.

SwiftyWasmer packages the
[Wasmer C API](https://github.com/wasmerio/wasmer-c-api)
for the Swift programming language, 
i.e. it provides `CWasmer` system library with a proper module map
and a `Wasmer` module with a nice Swift style API for Wasmer.

*Note*: This is for embedding/running 
[WebAssembly](https://webassembly.org) (Wasm)
modules from within a Swift host program. 
It is not about compiling Swift to WebAssembly
(there is the [SwiftWasm](https://swiftwasm.org) effort for this).

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
let results  = try instance.exports.sum(.i32(7), .i32(8))
```


## Wasmer Installation for Swift

This works on either Intel or M1 Macs.

Installing Wasmer itself is easy:
```sh
curl https://get.wasmer.io -sSfL | sh
```
Or install a tarball:
[Wasmer 1.0.0](https://github.com/wasmerio/wasmer/releases)
wherever you like.

To work, the 
[Swift Package Manager](https://github.com/apple/swift-package-manager)
requires a
[pkg-config](https://en.wikipedia.org/wiki/Pkg-config)
file in a system location.
_Fortunately_ `wasmer config` can generate one for you:
```sh
wasmer config --pkg-config > /usr/local/lib/pkgconfig/wasmer.pc
```

_Unfortunately_ the generated file is a
[little b0rked](https://github.com/wasmerio/wasmer/issues/1989) in 1.0.0.
Open up the file in your favorite editor:

```sh
emacs /usr/local/lib/pkgconfig/wasmer.pc
mate  /usr/local/lib/pkgconfig/wasmer.pc
open  /usr/local/lib/pkgconfig/wasmer.pc
```

And adjust two little things:

1. remove the `/wasmer` from the `Cflags` line, it should then read:
   `Cflags: -I/Users/helge/.wasmer/include`
2. add `-lffi` to the `Libs` line, it should then read:
   `Libs: -L/Users/helge/.wasmer/lib -lwasmer -lffi`

(the latter is only required when linking static libs, but doesn't hurt either
 way).

To link statically (recommended), move `libwasmer.dylib` out of the way:
```sh
mv ~/.wasmer/lib/libwasmer.dylib ~/.wasmer/lib/libwasmer.dylib-away
```
(Dynamic linking should also work, but you'd need to ensure that the dylib is
 in the dynamic library lookup path.)


### Links

- [Wasmer](https://wasmer.io)
  - [Documentation](https://docs.wasmer.io)
  - [Wasmer C API](https://github.com/wasmerio/wasmer-c-api)
- [WebAssembly](https://webassembly.org)
  - [Developers Guide](https://webassembly.org/getting-started/developers-guide/)
- [SwiftWasm](https://swiftwasm.org) (compiling Swift to Wasm)

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
