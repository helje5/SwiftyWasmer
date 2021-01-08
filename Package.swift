// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SwiftyWasmer",
  
  products: [
    .library   (name: "Wasmer",    targets: [ "Wasmer"    ]),
    .executable(name: "swasi-run", targets: [ "swasi-run" ])
  ],
  
  targets: [
    .systemLibrary(name: "CWasmer", pkgConfig: "wasmer"),
    
    .target(name: "Wasmer", dependencies: [ "CWasmer" ],
            exclude: [ "README.md", "CExtensions/README.md" ]),
                
    .target(name: "swasi-run", dependencies: [ "Wasmer" ])
  ]
)
