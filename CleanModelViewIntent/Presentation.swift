//
//  Presentation.swift
//  CleanMVI
//
//  Created by blakerogers on 2/28/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol Presentation: class {
    func bindUIActions(binder: @escaping (Presentation) -> Void)
    init()
}
extension Presentation {
    public func bindUIActions(binder: @escaping (Presentation) -> Void) {
        binder(self)
    }
}
