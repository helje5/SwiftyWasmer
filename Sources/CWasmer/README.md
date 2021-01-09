#  CWasmer

This is a SwiftPM system library which wraps the
libwasmer.a/.dylib.
It provides the 
[module map](https://clang.llvm.org/docs/Modules.html) 
necessary to import the C library into Swift.

Note that the system library needs a proper `wasmer.pc` pkgConfig file
in a system location, for example `/usr/local/lib/pkgconfg/`.

The `wasmer.pc` file can be generated using:
```bash
wasmer config --pkg-config > /usr/local/lib/pkgconfig/wasmer.pc
```

In the Wasmer 1.0.0 release this has two issues, which need to be fixed
manually:
- the `Cflags` have an extra `/wasmer` at the end, that needs to be dropped
- the `Libs` is missing the `-lffi` at the end

### Links

- [Wasmer](https://wasmer.io)
  - [Documentation](https://docs.wasmer.io)
  - [Wasmer C API](https://github.com/wasmerio/wasmer-c-api)

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
