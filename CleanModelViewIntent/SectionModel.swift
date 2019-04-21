//
//  SectionModel.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/8/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public protocol Item: class {
    var presenter: PresenterType? { get set}
    static var identifier: String {get}
}
extension Item {
    public static var identifier: String { return String(describing: self)}
}
public protocol ItemListenerType {}
public protocol ItemListener: ItemListenerType {
    associatedtype Model: SectionModel
    associatedtype ParentIntentType: Intent
    associatedtype ChildIntentType: Intent
    var childInteractor: Box<ChildIntentType?> {get set}
    var parentInteractor: Box<ParentIntentType?> {get set}
}
public protocol SectionModel {
    associatedtype ParentCoordinator: SceneCoordinator
    associatedtype Coordinator: ItemCoordinator
    associatedtype HeaderFooterType: Item
    static var isPaging: Bool { get set}
    static var numberOfSections: Int! { get set}
    static var interItemSpacing: CGFloat! {get set}
    func presenter(item: Coordinator.ItemLink.View) -> ItemPresenter<Coordinator.ItemLink>
    func numberOfItems(section: Int) -> Int
    func headerSize(path: IndexPath) -> CGSize
    func itemSize(reference: CGSize) -> CGSize
    func header(path: IndexPath) -> HeaderFooterType
    func footer(path: IndexPath) -> HeaderFooterType
    func implementCoordinator<Listener: ItemListener>(for item: Coordinator.ItemLink.View, indexPath: IndexPath, listener: Listener)
    func willEndDragging<Listener: ItemListener>(referenceSize: CGSize, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>, listener: Listener)
}
public class EmptySectionModelHeaderFooter: Item {
    public var presenter: PresenterType?
    public static var identifier: String = "NA"
    public required init(_ presenter: PresenterType?) {
    }
}
