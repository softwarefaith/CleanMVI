//
//  Service.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol Service: class {
    var serviceResult: Box<Result> { get set}
}
public protocol MVIService: Service {
//     var serviceHandler: (ServiceIntent?, ViewState) -> Void { get set}
}
public class NilServiceType: MVIService {
    public var serviceResult: Box<Result> = Box(EmptyResult.notSet)
}
