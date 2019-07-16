//
//  Presenter.swift
//  CleanMVI
//
//  Created by blakerogers on 2/28/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol PresenterType {}
public class Presenter<Link: PresenterLink>: ActionPresenter, Interactor, PresenterType {
    public typealias ViewType = Link.View
    public typealias ViewStateType = Link.Link.ViewStateType
    public typealias IntentType = Link.Link.IntentType
    public var interactor: Box<IntentType?> = Box(nil)
    public var presentation: Link.View
    var viewStateAction: ViewStateAction!
    var interaction: Interaction?
    public init(presentation: Link.View) {
        self.viewStateAction = Link.action
        self.interaction = Link.interaction
        self.presentation = presentation
        self.bindUIActions()
    }
    private func bindUIActions() {
        self.interaction?(presentation, interactor)
    }
    public func bindViewModel<VM: ViewModelType>(viewModel: VM) where VM.ViewStateType == ViewStateType {
        viewModel.viewState.bindListener { [weak self] state, prevState in
            guard let this = self else { return }
            guard let state = state else { return }
            this.viewStateAction(state, prevState, this.presentation)
            return
        }
        interactor.bindListener { intent, _ in
            guard let intent = intent as? VM.IntentType else { return }
            viewModel.intent.accept(intent)
        }
    }
}

