//
//  ItemCoordinator.swift
//  CleanModelViewIntent
//
//  Created by blakerogers on 3/8/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation

public protocol ItemCoordinator: class, CoordinatorType {
    associatedtype Link: ViewModelLink
    associatedtype ItemLink: ItemPresenterLink
    var viewModel: ViewModel<Link>! { get set}
    var itemPresenter: ItemPresenter<ItemLink>! { get set}
    init()
    func item() -> ItemLink.View
}
extension ItemCoordinator {
    public func item() -> ItemLink.View {
        return itemPresenter.item
    }
    public static func configureItem<IC: ItemCoordinator>(
        item: Item,
        viewModelDelegate: MVIDelegate?,
        service: MVIService?) -> IC where IC.ItemLink.Link == IC.Link.Link {
        let coordinator = IC()
        let viewModelType = ViewModel<IC.Link>(coordinator: coordinator, delegate: viewModelDelegate, service: service)
        coordinator.viewModel = viewModelType
        coordinator.itemPresenter = ItemPresenter<IC.ItemLink>(item: item as! IC.ItemLink.View)
        return coordinator
    }
    public static func makeCoordinator<IC: ItemCoordinator>(item: Item) -> IC where IC.ItemLink.Link == IC.Link.Link {
        
        return IC.configureItem(item: item, viewModelDelegate: nil, service: nil)
    }
}
