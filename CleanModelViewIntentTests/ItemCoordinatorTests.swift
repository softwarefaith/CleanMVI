//
//  ItemCoordinatorTests.swift
//  CleanModelViewIntentTests
//
//  Created by blakerogers on 3/8/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//
import XCTest
@testable import CleanModelViewIntent
class ItemCoordinatorTests: XCTestCase {
    var itemCoordinator: MockItemCoordinator!
    var parentCoordinator: MockParentSceneCoordinator!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
//        itemCoordinator = MockItemCoordinator.configureItem(presenter: ItemPresenter<MockItemCoordinator>(), viewModelDelegate: nil, service: nil, listener: <#Listener#>)
//        parentCoordinator = MockParentSceneCoordinator.configure(action: MockParentPresenter.action, interaction: MockParentPresenter.binder, viewModelDelegate: nil, service: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testsMockItemViewInitialState() {
        let item = itemCoordinator.itemPresenter.item
        XCTAssertEqual(item.label, "")
    }
    func testsPassMockItemInitialState() {
        itemCoordinator.itemPresenter.interactor.accept(MockItemViewModel.MockItemIntent.initial("Item1"))
        let viewState = itemCoordinator.viewModel.viewState.element()
        XCTAssertEqual(viewState?.itemName ?? "", "Item1")
    }
    func testsMockItemViewFinalState() {
        let item = itemCoordinator.itemPresenter.item
        item.stateText.accept("Item2")
        let viewState = itemCoordinator.viewModel.viewState.element()
        XCTAssertEqual(viewState?.itemName ?? "", "Item2")
    }
}
extension ItemCoordinatorTests {
    final class MockItemListener: ItemListener {
        typealias ChildIntentType = MockItemViewModel.MockItemIntent
        var childInteractor: Box<ItemCoordinatorTests.MockItemViewModel.MockItemIntent>! = Box(ChildIntentType.initial(""))
    }
    final class MockParentSceneCoordinator: SceneCoordinator {
        typealias ViewStateType = MockParentViewModel.MockParentViewState
        typealias IntentType = MockParentViewModel.MockParentIntent
        typealias View = MockParentView
        typealias RouterType = MockParentRouter
        var coordinators: [String : Coordinator] = [:]
        var viewModel: MVIViewModelType!
        var presenter: Presenter<MockParentSceneCoordinator>!
        var router: MockParentRouter!
    }
    final class MockParentView: Presentation, Controller {
        var presenter: PresenterType?
        required init() {}
    }
    class MockParentRouter: Router {
        var coordinator: Coordinator
        
        var controller: Controller
        
        var route: (RoutedIntent?, ViewState) -> Void = { intent, viewState in
        }
        
        required init(controller: Controller, coordinator: Coordinator) {
            self.controller = controller
            self.coordinator = coordinator
        }
    }
    struct MockParentViewModel {
        enum MockParentIntent: Intent, ActionIntent {
            case initial(String)
            case didSetName(String)
            case didSelectViewName
            func implementAction() -> Result {
                switch self {
                case let .initial(name):
                    return MockParentResult.initial(name)
                case let .didSetName(name):
                    return MockParentResult.setName(name)
                default: return ResultState.notSet
                }
            }
        }
        enum MockParentResult: Result, Reducing {
            case initial(String)
            case setName(String)
            func reduce(accumViewState: ViewState?) -> ViewState {
                switch  self  {
                case let .initial(name):
                    return MockParentViewState(name: name)
                case let .setName(name):
                    return MockParentViewState(name: name)
                }
            }
        }
        struct MockParentViewState: ViewState {
            let name: String
        }
    }
    struct MockParentPresenter: PresenterLink {
        typealias ViewStateType = MockParentViewModel.MockParentViewState
        typealias View = MockParentView
        typealias IntentType = MockParentViewModel.MockParentIntent
        static var action: (MockParentViewModel.MockParentViewState, MockParentViewModel.MockParentViewState, MockParentView) -> Void =
        { viewState, _, view in
            
        }
        static var binder: (MockParentView, Box<MockParentViewModel.MockParentIntent?>) -> Void =
        {
            view, interactor in
        }
    }
    final class MockItemCoordinator: ItemCoordinator {
        typealias ViewStateType = MockItemViewModel.MockItemViewState
        typealias IntentType = MockItemViewModel.MockItemIntent
        typealias View = MockItemView
        typealias Link = MockItemPresenter
        var coordinators: [String : Coordinator] = [:]
        var viewModel: ViewModel<ViewStateType, IntentType>!
        var itemPresenter: ItemPresenter<MockItemCoordinator>!
    }
    final class MockItemView: Item {
        var presenter: PresenterType?
        static var identifier: String = ""
        var label: String = ""
        let stateText: Box<String> = Box("")
        required init(){}
        
    }
    struct MockItemViewModel {
        enum MockItemIntent: Intent, ActionIntent {
            case initial(String)
            case didSelectViewItemName
            func implementAction() -> Result {
                switch self {
                case let .initial(name):
                    return MockItemResult.initial(name)
                default: return ResultState.notSet
                }
            }
        }
        enum MockItemResult: Result, Reducing {
            case initial(String)
            func reduce(accumViewState: ViewState?) -> ViewState {
                switch self {
                case let .initial(name):
                    return MockItemViewState(itemName: name)
                }
            }
        }
        struct MockItemViewState: ViewState {
            let itemName: String
        }
    }
    struct MockItemPresenter: PresenterLink {
        typealias View = MockItemView
        typealias ViewStateType = MockItemViewModel.MockItemViewState
        typealias IntentType = MockItemViewModel.MockItemIntent
        static var action: (ViewStateType?, ViewStateType?, View) -> Void = { state, _, view in
            view.label = state.itemName
        }
        static var binder: (View, Box<IntentType?>) -> Void = { view, interactor in
            view.stateText.bindListener { text, _ in
                interactor.accept(IntentType.initial(text))
            }
        }
    }
}
