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
    associatedtype ServiceType: Service
    associatedtype DelegateType: MVIDelegate
    static var intentHandler: ((Link.IntentType) -> Link.ResultType)? { get }
    static var partialResultHandler: ((Result) -> Link.ResultType?)? { get }
    static var serviceHandler: ((Link.IntentType, Link.ViewStateType, ServiceType?) -> Void)? { get }
    static var delegateHandler: ((Link.IntentType, Link.ViewStateType, DelegateType?) -> Void)? { get }
    static var initialIntent: Link.IntentType? { get}
    static func reduce(viewState: Link.ViewStateType?, result: Link.ResultType?) -> Link.ViewStateType?
}
public class ViewModel<Link: ViewModelLink>: ViewModelType {
    public typealias ViewStateType = Link.Link.ViewStateType
    public typealias IntentType = Link.Link.IntentType
    public typealias ResultType = Link.Link.ResultType
    public typealias ServiceType = Link.ServiceType
    public typealias DelegateType = Link.DelegateType
    // MARK: - Input
    public var intent: Box<IntentType?> = Box(nil)
    public var viewState: Box<ViewStateType?> = Box(nil)
    public var result: Box<ResultType?> = Box(nil)
    var partialResult: Box<Result> = Box(EmptyResult.notSet)
    // MARK: - Stored Properties
    public var coordinator: CoordinatorType?
    public var delegate: DelegateType?
    public var service: ServiceType?
    // MARK: - Output
    public var intentHandler = Link.intentHandler
    public var partialResultHandler = Link.partialResultHandler
    // MARK: - Initializer
    public init(coordinator: CoordinatorType? = nil, delegate: DelegateType? = nil, service: ServiceType? = nil) {
        self.coordinator = coordinator
        self.delegate = delegate
        self.service = service
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
            self.result.accept(Link.intentHandler?(intent))
        }
        intent.bindListener { [weak self] intent, _  in
            guard let intent = intent else { return }
            guard let this = self else { return }
            guard let state = this.viewState.element() else { return }
            Link.delegateHandler?(intent, state, self?.delegate)
            Link.serviceHandler?(intent, state, self?.service)
        }
        intent.bindListener { intent, _ in
            guard let intent = intent, intent is DelayedIntent else { return }
            self.result.accept(Link.intentHandler?(intent))
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
            guard let result = self?.partialResultHandler?(partialResult) else {return}
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

