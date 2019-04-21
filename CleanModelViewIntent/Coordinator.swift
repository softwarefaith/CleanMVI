//
//  Coordinator.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol CoordinatorType {
}
public protocol Coordinator: class, CoordinatorType {
    static var identifier: String {get}
    var coordinators: [String: Coordinator] { get set}
    func pushCoordinator<C: Coordinator>(_ coordinator: C)
    func popCoordinator(_ identifier: String)
    func fetch(identifier: String) -> Coordinator?
}
public extension Coordinator {
    public static var identifier: String { return String(describing: self)}
    public func pushCoordinator<C: Coordinator>(_ coordinator: C) {
        coordinators[C.identifier] = coordinator
    }
    public func popCoordinator(_ identifier: String) {
        coordinators.removeValue(forKey: identifier)
    }
    public func fetch(identifier: String) -> Coordinator? {
        return coordinators[identifier]
    }
}
