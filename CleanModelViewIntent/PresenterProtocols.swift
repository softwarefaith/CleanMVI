//
//  PresenterProtocols.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/9/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
protocol ActionPresenter {
    associatedtype ViewStateType
    associatedtype ViewType
    associatedtype ViewStateAction = (ViewStateType?, ViewStateType?, ViewType) -> Void
    var viewStateAction: ViewStateAction! {get}
}
public protocol Interactor {
    associatedtype ViewType
    associatedtype IntentType
    associatedtype Interaction = (ViewType, Box<IntentType?>) -> Void
    var interactor: Box<IntentType?> { get set}
}
public protocol CanInit {
    init()
}
public protocol PresenterLink {
    associatedtype Link: ViewStateIntentLink
    associatedtype View
    static var action: (Link.ViewStateType?, Link.ViewStateType?, View) -> Void { get}
    static var interaction: (View, Box<Link.IntentType?>) -> Void { get}
}
public protocol ItemPresenterLink {
    associatedtype View: Item
    associatedtype Link: ViewStateIntentLink
    static var action: (Link.ViewStateType?, Link.ViewStateType?, View) -> Void { get}
    static var interaction: (View, Box<Link.IntentType?>) -> Void { get}
}
