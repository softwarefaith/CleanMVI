//
//  CommonStates.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation
public enum DisplayState: MappedProperty {
    case display
    case notDisplayed
    var alternate: DisplayState {
        switch self {
        case .display: return .notDisplayed
        case .notDisplayed: return .display
        }
    }
    public func equals(_ rhs: Any) -> Bool {
        guard let state = rhs as? DisplayState else { return false}
        switch (self, state) {
        case (.display, .display), (.notDisplayed, .notDisplayed): return true
        default: return false
        }
    }
}
public enum ResultState: Result {
    case notSet
    case loading
    case error
    case success
}
public enum ErrorState {
    case none
    case error(message: String)
}
extension ErrorState: Equatable {
    public static func ==(lhs: ErrorState, rhs: ErrorState) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error), (.none, .none): return true
        default: return false
        }
    }
}
