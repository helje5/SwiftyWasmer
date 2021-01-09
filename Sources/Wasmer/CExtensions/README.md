#  Wasmer / CExtensions

This folder contains extensions to the Wasmer C API structs,
or pointers thereof.

Just to cleanup the API a little from a Swift perspective.

The "const'ness" of pointers doesn't seem to be declared properly in the
Wasmer C API.
This results in many API calls taking mutable pointers when they are not
actually mutable.

### Links

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
