//
//  Box.swift
//  CleanMVI
//
//  Created by blakerogers on 2/27/19.
//  Copyright © 2019 blakerogers. All rights reserved.
//

import Foundation

public class Box<T> {
    public typealias Value = T
    public typealias Listener = (Value, Value) -> Void
    public typealias ListenCondition = (Value) -> Bool
    public typealias ElementChange = (inout T) -> T
    public typealias Property = MappedProperty
    private var listeners: [Listener] = []
    private var listenerStates: [ListenerState<T>] = []
    private var value: T {
        didSet {
            //Notify Listeners
            for listener in listeners.enumerated() {
                let listenerIndex = listener.offset
                if listenerStates[listenerIndex].valueMutated(value: value) {
                    listener.element(value, oldValue)
                }
            }
        }
    }
    public init(_ value: T) {
        self.value = value
    }
    public func map(_ property: Property, _ bind: @escaping (Property) -> ()) {
        var matchingParameterKey: String = ""
        let mirror = Mirror(reflecting: self.value)
        for (key,value) in mirror.children {
            if property.equals(value) {
                matchingParameterKey = key ?? ""
            }
        }
        guard !matchingParameterKey.isEmpty else { return}
        self.bindListener { ( boxedObject, _) in
            let mirror2 = Mirror(reflecting: boxedObject)
            let paramater = mirror2.children.filter({ $0.label == matchingParameterKey})
            guard let value = paramater.first?.value  as? Property else { return }
            bind(value)
        }
    }
    /// Sets value to box value
    ///
    /// - Parameter value: T (Type correlating to type of value)
    public func accept(_ value: T) {
        self.value = value
    }
    public func takeChange( change: ElementChange) {
        accept(change(&value))
    }
    /// Provide copy of internal value
    ///
    /// - Returns: T
    public func element() -> T {
        return self.value
    }
    /// Binds any listener function to a change to the contained value
    ///
    /// - Parameter listener: Listener, function that fires due to change
    public func bind(_ listener: @escaping Listener, take limit: Int = Int.max, skip: Int = 0, unless condition: ListenCondition? = nil) {
        listeners.append(listener)
        var listenerState = ListenerState<T>(limit: limit, skips: skip, timesObserved: 0, condition: condition)
        listenerStates.append(listenerState)
        guard skip == 0 else { return }
        if listenerState.valueMutated(value: value) {
            listener(value, value)
            listenerStates[listenerStates.count-1] = listenerState
        }
    }
    /// Binds any listener function to a change to the contained value
    ///
    /// - Parameter listener: Listener, function that fires due to change
    public func bindListener(_ listener: @escaping Listener) {
        listeners.append(listener)
        listenerStates.append(ListenerState())
        listener(value, value)
    }
    /// Remove all listeners
    public func removeListeners() {
        listeners.removeAll()
    }
    public func numberOfListeners() -> Int {
        return listeners.count
    }
    public func numberOfListenerStates() -> Int {
        return listenerStates.count
    }
    private func listenerState(at index: Int) -> ListenerState<T> {
        guard listenerStates.count > index else { return ListenerState()}
        return listenerStates[index]
    }
    /// Object to monitor listener state to provide extended variability for listeners
    fileprivate struct ListenerState<T> {
        private let limit: Int
        private let skips: Int
        private var timesObserved: Int
        private var timesExecuted: Int
        private let condition: ListenCondition
        init(limit: Int = Int.max, skips: Int = 0, timesObserved: Int = 0, condition: ListenCondition? = nil) {
            assert(skips >= 0, "Skips cannot be less than 0")
            assert(limit >= 1, "Limit cannot be less than 1")
            self.limit = limit
            self.skips = skips
            self.timesObserved = timesObserved
            self.timesExecuted = 0
            self.condition = condition ?? { _ in return true}
        }
        /// Evaluates listener state and value, true if conditions for execution met
        ///
        /// - Parameter value: Value
        /// - Returns: Bool
        private func shouldExecute(value: Value) -> Bool {
            let conditionValid = condition(value)
            let limitsNotExceeded = limit > timesExecuted
            let skipsMet = timesObserved >= skips
            return  conditionValid && limitsNotExceeded && skipsMet
        }
        /// Observes property mutation and returns if an execution should occur
        ///
        /// - Parameter value: Value
        /// - Returns: Bool
        mutating func valueMutated(value: Value) -> Bool {
            timesObserved += 1
            if shouldExecute(value: value) {
                timesExecuted += 1
                return true
            }
            return false
        }
        /// Provides number of times value mutation observed
        ///
        /// - Returns: Int
        public func numberOfTimesObserved() -> Int {
            return self.timesObserved
        }
        /// Provides number of times listener executed
        ///
        /// - Returns: Int
        public func numberOfTimesExecuted() -> Int {
            return self.timesExecuted
        }
    }
}

