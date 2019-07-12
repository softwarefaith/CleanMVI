//
//  Delegate.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol Delegate: class{}
public protocol MVIDelegate: Delegate {
//    var delegateHandler: (DelegateIntent?, ViewState) -> Void { get set}
}
public class NilDelegateType: MVIDelegate {}
