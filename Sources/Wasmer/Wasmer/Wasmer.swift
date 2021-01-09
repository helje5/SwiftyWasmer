//
//  Wasmer.swift
//  Wasmer / Wasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

import CWasmer

public enum Wasmer {}

public extension Wasmer {
  
  static var version : ( major: Int, minor: Int, patch : Int ) {
    return ( Int(wasmer_version_major()),
             Int(wasmer_version_minor()),
             Int(wasmer_version_patch()) )
  }
}
