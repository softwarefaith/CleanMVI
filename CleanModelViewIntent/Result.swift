//
//  Result.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol Result {}

enum EmptyResult: Result {
    case notSet
}
