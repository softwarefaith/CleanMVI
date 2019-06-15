//
//  ItemPresenter.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/9/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public class ItemPresenter<Link: ItemPresenterLink>: ActionPresenter, Interactor, PresenterType {
    public typealias ViewType = Link.View
    public typealias ViewStateType = Link.Link.ViewStateType
    public typealias IntentType = Link.Link.IntentType
    public var interactor: Box<IntentType?> = Box(nil)
    public var item: Link.View!
    var viewStateAction: ViewStateAction!
    var interaction: Interaction?
    var itemListener: ItemListenerType!
    public init(item: Link.View?) {
        self.viewStateAction = Link.action
        self.interaction = Link.interaction
        self.item = item
        self.bindUIActions()
    }
    private func bindUIActions() {
        self.interaction?(item, interactor)
    }
    public func bindViewModel<VM: ViewModelType, Listener: ItemListener>(viewModel: VM, listener: Listener) where VM.ViewStateType == ViewStateType {
        self.itemListener = listener
        viewModel.viewState.bindListener { [weak self] state, prevState in
            guard let this = self else { return }
            guard let state = state else { return }
            this.viewStateAction(state, prevState, this.item)
            return
        }
        interactor.bindListener { intent, _ in
            guard let intent = intent else { return }
            viewModel.intent.accept(intent as? VM.IntentType)
            listener.childInteractor.accept(intent)
        }
        
    }
}
