//
//  Router.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/3/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol RouterInfo {}
public protocol RouterDelegate: class {
    func dismiss()
    func dismissWith(info: RouterInfo)
}
public protocol RouterLink {
    associatedtype Link: ViewStateIntentLink
    static var route: (Link.ViewStateType?, Link.IntentType, Router<Self>) -> Void {get}
    static var onDismiss: () -> Void { get }
    static var onDismissWithInfo: (RouterInfo) -> Void { get }
}
open class Router<Link: RouterLink>: RouterDelegate {
    public var routerDelegate: RouterDelegate?
    public var coordinator: Coordinator
    public var controller: Controller
    let route = Link.route
    let onDismiss = Link.onDismiss
    let onDimissWithInfo = Link.onDismissWithInfo
    init<VMLink: ViewModelLink>(controller: Controller, coordinator: Coordinator, viewModel: ViewModel<VMLink>) where VMLink.Link == Link.Link {
        self.controller = controller
        self.coordinator = coordinator
        viewModel.intent.bindListener { intent, _ in
            let state = viewModel.viewState.element()
            guard let intent = intent else { return }
            Link.route(state, intent, self)
        }
    }
}
extension Router {
    public func dismiss() {
        self.onDismiss()
    }
    public func dismissWith(info: RouterInfo) {
        self.onDimissWithInfo(info)
    }
}
