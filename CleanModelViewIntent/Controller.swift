//
//  Controller.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/3/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
import UIKit
public typealias ControllerDismissClosure = () -> Void
public typealias ControllerArrangement = (Controller) -> Void
public protocol Controller: class {
    func remove(animated: Bool, animation: ControllerDismissClosure?)
    func present(controller: Controller, animated: Bool, arrange: ControllerArrangement?)
    func push(controller: Controller, animated: Bool, arrange: ControllerArrangement?)
    func pop(controller: Controller, animated: Bool, arrange: ControllerArrangement?)
    func set(controllers: [Controller], animated: Bool, arrange: ControllerArrangement?)
    func addChild(controller: Controller, arrange: ControllerArrangement?)
    func view() -> UIViewController
    init()
}
extension UIViewController: Controller {
    public static var identifier: String { return self.init().title ?? ""}
    public var identifier: String { return self.title ?? ""}
    public func view() -> UIViewController {
        return self
    }
    public func present(controller: Controller, animated: Bool, arrange: ControllerArrangement?) {
        guard let controller = controller as? Controller & UIViewController else { return }
        present(controller, animated: animated, completion: {
            arrange?(controller)
        })
    }
    public func remove(animated: Bool, animation: ControllerDismissClosure?) {
        dismiss(animated: animation != nil) {
            animation?()
        }
    }
    public func push(controller: Controller, animated: Bool, arrange: ControllerArrangement?){
        
    }
    public func pop(controller: Controller, animated: Bool, arrange: ControllerArrangement?){
        
    }
    public func set(controllers: [Controller], animated: Bool, arrange: ControllerArrangement?){
        
    }
    public func addChild(controller: Controller, arrange: ControllerArrangement?){
        
    }
}
