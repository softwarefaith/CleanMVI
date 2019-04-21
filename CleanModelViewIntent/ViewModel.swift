//
//  ViewModel.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//
import Foundation
public protocol MVIViewModelType {}
public protocol ViewStateIntentLink {
    associatedtype ViewStateType: ViewState
    associatedtype IntentType: Intent
    associatedtype ResultType: Result
}
public protocol OutputsViewState {
    associatedtype ViewStateType: ViewState
    var viewState: Box<ViewStateType?> { get set}
}
public protocol Inputs {
    associatedtype IntentType
    var intent: Box<IntentType?> { get set}
}
public protocol ViewModelType: MVIViewModelType, Inputs, OutputsViewState {}
public protocol ViewModelLink {
    associatedtype Link: ViewStateIntentLink
    associatedtype ServiceHandler = (ServiceIntent?, Link.ViewStateType) -> Void
    associatedtype DelegateHandler = (DelegateIntent?, Link.ViewStateType) -> Void
    static var intentHandler: (Link.IntentType) -> Link.ResultType { get }
    static var partialResultHandler: (Result) -> Link.ResultType? { get }
    static var serviceHandler: ServiceHandler? { get }
    static var delegateHandler: DelegateHandler? { get }
    static var initialIntent: Link.IntentType? { get}
    static func reduce(viewState: Link.ViewStateType?, result: Link.ResultType?) -> Link.ViewStateType?
}
public class ViewModel<Link: ViewModelLink>: ViewModelType {
    public typealias ViewStateType = Link.Link.ViewStateType
    public typealias IntentType = Link.Link.IntentType
    public typealias ResultType = Link.Link.ResultType
    public typealias ServiceHandler = (ServiceIntent?, ViewStateType) -> Void
    public typealias DelegateHandler = (DelegateIntent?, ViewStateType) -> Void
    // MARK: - Input
    public var intent: Box<IntentType?> = Box(nil)
    public var viewState: Box<ViewStateType?> = Box(nil)
    public var result: Box<ResultType?> = Box(nil)
    var partialResult: Box<Result> = Box(EmptyResult.notSet)
    // MARK: - Stored Properties
    public var coordinator: CoordinatorType?
    public var delegate: Delegate?
    public var service: MVIService?
    // MARK: - Output
    public var serviceHandler: ServiceHandler?
    public var delegateHandler: DelegateHandler?
    public var intentHandler = Link.intentHandler
    public var partialResultHandler = Link.partialResultHandler
    // MARK: - Initializer
    public init(coordinator: CoordinatorType? = nil, delegate: MVIDelegate? = nil, service: MVIService? = nil) {
        self.coordinator = coordinator
        self.delegate = delegate
        self.service = service
        self.serviceHandler = service?.serviceHandler
        self.delegateHandler = delegate?.delegateHandler
        configure()
        self.intent.accept(Link.initialIntent)
    }
}
extension ViewModel {
    /// bind intent and bind results
    public func configure() {
        bindIntent()
        bindResults()
        bindService()
    }
    /// Observe intents received from view
    internal func bindIntent() {
        intent.bindListener { intent,_ in
            guard let intent = intent, intent is ActionIntent else { return }
            self.result.accept(Link.intentHandler(intent))
        }
        intent.bindListener { [weak self] intent, _  in
            guard let intent = intent else { return }
            guard let this = self else { return }
            guard let state = this.viewState.element() else { return }
            self?.delegateHandler?(intent as? DelegateIntent, state)
            self?.serviceHandler?(intent as? ServiceIntent, state)
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
    internal func bindService() {
        service?.serviceResult.bindListener({ result, _ in
            self.partialResult.accept(result)
        })
    }
    public func dismissAllListeners() {
        viewState.removeListeners()
        intent.removeListeners()
        result.removeListeners()
    }
}

