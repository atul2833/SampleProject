//
//  ReachabilityWrapper.swift
//  ComeraPay
//
//  Created by Muhammad Ahmed Baig on 30/01/2024.
//

import Foundation
import Combine

final class ReachabilityWrapper {
    
    static let shared = ReachabilityWrapper()
    private let reachability: Reachability!
    var subscriptions = Set<AnyCancellable>()
    
    var isInternetConnected: Bool = true
    
    private init() {
        reachability = try? Reachability()
        self.observeChanges()
    }
    
    func startObserving() {
        try? reachability.startNotifier()
    }

    func observeChanges() {
        reachability?.status
            .sink(receiveValue: { status in
                Log.info("Reachability status changed: \(status)")
                self.isInternetConnected = status != .unavailable
            }).store(in: &subscriptions)

        reachability?.isConnected
            .sink(receiveValue: {
                Log.info("Is connected")
                self.isInternetConnected = true
            }).store(in: &subscriptions)

        reachability?.isDisconnected
            .sink(receiveValue: {
                Log.info("Is disconnected")
                self.isInternetConnected = false
            }).store(in: &subscriptions)
    }
}
