//
//  SceneCoordinator.swift
//  CleanMVI
//
//  Created by blakerogers on 2/28/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation

public protocol SceneCoordinator: Coordinator {
    associatedtype Link: ViewModelLink
    associatedtype ViewLink: PresenterLink where Link.Link == ViewLink.Link
    associatedtype RouteLink: RouterLink where Link.Link == RouteLink.Link
    var parentCoordinator: Coordinator? { get set }
    var viewModel: MVIViewModelType! { get set }
    var presenter: Presenter<ViewLink>! { get set }
    var router: Router<RouteLink>! { get set }
    init()
}
extension SceneCoordinator {
    public var currentController: Controller {
        return presenter!.presentation as! Controller
    }
    public static func configure<SC: SceneCoordinator>(
        viewModelDelegate: SC.Link.DelegateType?,
        service: SC.Link.ServiceType?) -> SC {
        let coordinator = SC()
        let presentation = coordinator.controller()
        let presenter = Presenter<SC.ViewLink>(presentation: presentation as! SC.ViewLink.View)
        let viewModelType = ViewModel<SC.Link>(coordinator: coordinator, delegate: viewModelDelegate, service: service)
        coordinator.viewModel = viewModelType
        coordinator.presenter = presenter
        coordinator.presenter.bindViewModel(viewModel: viewModelType)
        coordinator.router = Router<SC.RouteLink>(controller: presentation, coordinator: coordinator, viewModel: viewModelType)
        return coordinator
    }
}

