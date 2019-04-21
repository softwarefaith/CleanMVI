//
//  MappedProperty.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/1/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol MappedProperty {
    func equals(_ rhs: Any) -> Bool
}
extension String: MappedProperty {
    public func equals(_ rhs: Any) -> Bool {
        guard let string = rhs as? String else { return false}
        return self == string
    }
}
