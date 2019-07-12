//
//  ItemViewModel.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 6/20/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol ItemViewModelLink {
    associatedtype Link: ViewStateIntentLink
    static var intentHandler: (Link.IntentType) -> Link.ResultType { get }
    static var partialResultHandler: (Result) -> Link.ResultType? { get }
    static var initialIntent: Link.IntentType? { get}
    static func reduce(viewState: Link.ViewStateType?, result: Link.ResultType?) -> Link.ViewStateType?
}
public class ItemViewModel<Link: ItemViewModelLink>: ViewModelType {
    public typealias ViewStateType = Link.Link.ViewStateType
    public typealias IntentType = Link.Link.IntentType
    public typealias ResultType = Link.Link.ResultType
    // MARK: - Input
    public var intent: Box<IntentType?> = Box(nil)
    public var viewState: Box<ViewStateType?> = Box(nil)
    public var result: Box<ResultType?> = Box(nil)
    var partialResult: Box<Result> = Box(EmptyResult.notSet)
    // MARK: - Stored Properties
    public var coordinator: CoordinatorType?
    // MARK: - Output
    public var intentHandler = Link.intentHandler
    public var partialResultHandler = Link.partialResultHandler
    // MARK: - Initializer
    public init(coordinator: CoordinatorType? = nil) {
        self.coordinator = coordinator
        configure()
        self.intent.accept(Link.initialIntent)
    }
}
extension ItemViewModel {
    /// bind intent and bind results
    public func configure() {
        bindIntent()
        bindResults()
    }
    /// Observe intents received from view
    internal func bindIntent() {
        intent.bindListener { intent,_ in
            guard let intent = intent, intent is ActionIntent else { return }
            self.result.accept(Link.intentHandler(intent))
        }
        intent.bindListener { intent, _ in
            guard let intent = intent, intent is DelayedIntent else { return }
            self.result.accept(Link.intentHandler(intent))
        }
    }
    /// Bind Results from Actions
    internal func bindResults() {
        result.bind({ [weak self] result, _ in
            guard let this = self else { return }
            guard let newState = Link.reduce(viewState: this.viewState.element(), result: result) else {return}
            this.viewState.accept(newState)
        })
        partialResult.bindListener { [weak self] partialResult, _ in
            guard let result = self?.partialResultHandler(partialResult) else {return}
            self?.result.accept(result)
        }
    }
    public func dismissAllListeners() {
        viewState.removeListeners()
        intent.removeListeners()
        result.removeListeners()
    }
}
