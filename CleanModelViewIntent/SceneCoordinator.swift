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
    associatedtype ViewLink: PresenterLink
    associatedtype RouteLink: RouterLink where Link.Link == RouteLink.Link
    var viewModel: MVIViewModelType! { get set}
    var presenter: Presenter<ViewLink>! { get set}
    var router: Router<RouteLink>! { get set}
    init()
}
extension SceneCoordinator {
    public static func configure<SC: SceneCoordinator>(
        viewModelDelegate: MVIDelegate?,
        service: MVIService?) -> SC where SC.ViewLink.Link == SC.Link.Link {
        let coordinator = SC()
        let presentation = SC.ViewLink.View()
        let presenter = Presenter<SC.ViewLink>(presentation: presentation)
        let controller = presenter.presentation
        let viewModelType = ViewModel<SC.Link>(coordinator: coordinator, delegate: viewModelDelegate, service: service)
        coordinator.viewModel = viewModelType
        coordinator.presenter = presenter
        coordinator.presenter.bindViewModel(viewModel: viewModelType)
        coordinator.router = Router<SC.RouteLink>(controller: controller, coordinator: coordinator, viewModel: viewModelType)
        return coordinator
    }
}

