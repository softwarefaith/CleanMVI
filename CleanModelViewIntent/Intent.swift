//
//  Intent.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation

/// Base Intent Type
public protocol Intent {}
/// Intent Type that produces an immediate Result
public protocol ActionIntent {}
/// Intent Type that calls a delegate function
public protocol DelegateIntent {}
/// Intent Type that calls a service function
public protocol ServiceIntent {}
/// Intent Type that should occur the latest
public protocol DelayedIntent {}
public enum EmptyIntent: Intent {
    case notSet
}
