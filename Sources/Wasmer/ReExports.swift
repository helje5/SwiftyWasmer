//
//  ReExports.swift
//  Wasmer
//
//  Created by Helge Heß.
//  Copyright © 2021 ZeeZide GmbH. All rights reserved.
//

// To avoid having to explicitly import Foundation, just to get access to
// `URL` and `Data`.

import struct Foundation.Data
import struct Foundation.URL

public typealias Data = Foundation.Data
public typealias URL  = Foundation.URL
