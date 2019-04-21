//
//  CleanModelViewIntentTests.swift
//  CleanModelViewIntentTests
//
//  Created by blakerogers on 2/28/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import XCTest
@testable import CleanModelViewIntent

class CleanModelViewIntentTests: XCTestCase {
    var coordinator: MockSceneCoordinator!
    var viewModel: MVIViewModelType!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        coordinator = MockSceneCoordinator.configure(action: MockPresenter.action, interaction: MockPresenter.binder, viewModelDelegate: nil, service: nil, initial: MockViewModel.MockIntent.initial("Anthony"))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    func testsMockViewInitialState() {
        let presenter = coordinator.presenter.presentation
        XCTAssertEqual(presenter.label, "")
    }
    func testsPassMockInitialState() {
        coordinator.presenter.interactor.accept(MockViewModel.MockIntent.initial("Rogers"))
        let presenter = coordinator.presenter.presentation
        XCTAssertEqual(presenter.label, "Rogers")
    }
    func testsMockViewFinalState() {
        let presenter = coordinator.presenter.presentation
        presenter.stateText.accept("Blake")
        XCTAssertEqual(presenter.label, "Blake")
    }
    func testUseCaseRouter() {
        let presenter = coordinator.presenter.presentation
        presenter.initiate.accept(true)
        XCTAssertEqual(coordinator.router.shouldRouteNow, true)
    }
}
protocol MockUseCase {
    func shouldRoute()
}
extension CleanModelViewIntentTests {
    final class MockSceneCoordinator: SceneCoordinator {

        typealias ViewStateType = MockViewModel.MockViewState
        
        typealias IntentType = MockViewModel.MockIntent
        
        typealias View = MockView
        
        typealias RouterType = MockRouter
        
        var coordinators: [String : Coordinator] = [:]
        
        var viewModel: MVIViewModelType!
        
        var presenter: Presenter<MockSceneCoordinator>!
        
        var router: CleanModelViewIntentTests.MockRouter!
    }
    
    struct MockViewModel {
        struct MockViewState: ViewState {
            let state: String
        }
        enum MockIntent: Intent, ActionIntent, RoutedIntent {
            case initial(String)
            case final(String)
            case route
            func implementAction() -> Result {
                switch self {
                case let .initial(text):
                    return MockResult.initial(text)
                case let .final(text):
                    return MockResult.final(text)
                default: return ResultState.notSet
                }
            }
        }
        enum MockResult: Result, Reducing {
            case initial(String)
            case final(String)
            func reduce(accumViewState: ViewState?) -> ViewState {
                switch self {
                case let .initial(text):
                    return MockViewState(state: text)
                case let .final(text):
                    return MockViewState(state: text)
                }
            }
        }
    }
    final class MockView: Presentation, Controller {
        var presenter: PresenterType?
        var label: String = ""
        var stateText: Box<String> = Box("")
        var initiate: Box<Bool> = Box(false)
    }
    struct MockPresenter: PresenterLink {
        typealias View = MockView
        typealias ViewStateType = MockViewModel.MockViewState
        typealias IntentType = MockViewModel.MockIntent
        static var action: (ViewStateType?, ViewStateType?, View) -> Void = { state, _, view in
            view.label = state.state
        }
        static var binder: (View, Box<IntentType?>) -> Void = { view, interactor in
            view.stateText.bindListener { text, _ in
                interactor.accept(IntentType.final(text))
            }
            view.initiate.bind({ shouldRoute, _ in
                interactor.accept(IntentType.route)
            }, unless: { shouldRoute in
                return shouldRoute == true
            })
        }
    }
    class MockRouter: Router, MockUseCase {
        var coordinator: Coordinator
        
        var controller: Controller
        
        var shouldRouteNow: Bool = false
        
       lazy var route: (RoutedIntent?, ViewState) -> Void = { [weak self] intent, viewState in
            switch intent as? MockViewModel.MockIntent {
            case .route?:
                self?.shouldRoute()
            default: break
            }
        }
        required init(controller: Controller, coordinator: Coordinator) {
            self.controller = controller
            self.coordinator = coordinator
        }
        func shouldRoute() {
            shouldRouteNow = true
        }
    }
}
