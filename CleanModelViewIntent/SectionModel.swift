//
//  SectionModel.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/8/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
import UIKit
public protocol ItemType {}
public protocol Item: class, ItemType {
    var viewModel: MVIViewModelType! { get set}
    var presenter: PresenterType! {get set}
    static var identifier: String { get}
    init()
}
extension Item {
    public static var identifier: String { return String.init(describing: self)}
}
public protocol ItemListenerType {}
public protocol ItemListener: ItemListenerType {
    associatedtype Model: SectionModel
    var childInteractor: Box<Intent?> {get set}
    var parentInteractor: Box<Intent?> {get set}
}
public protocol SectionModel {
    associatedtype ParentViewState = ViewState
    static var isPaging: Bool { get set}
    static var numberOfSections: Int! { get set}
    static var interItemSpacing: CGFloat! {get set}
    static var minimumLineSpacing: CGFloat { get set}
    static var registrationItems: [(AnyClass?, String)] { get set}
    static var actionForViewState: (ParentViewState, ParentViewState?, UICollectionView) -> Void { get }
    var viewState: ParentViewState! { get set}
    func numberOfItems(section: Int) -> Int
    func headerSize(path: IndexPath) -> CGSize
    func itemSize(reference: CGSize, indexPath: IndexPath) -> CGSize
    func implementCell<Listener: ItemListener>(for item: UIView, indexPath: IndexPath, listener: Listener)
    func willEndDragging<Listener: ItemListener>(referenceSize: CGSize, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, listener: Listener)
    func item(collection: UIView, indexPath: IndexPath) -> UIView
}
