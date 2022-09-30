//
//  Paywall.swift
//  PaywallTemplate
//
//  Created by dDomovoj on 6/14/22.
//

import Foundation

import Stored

public enum Paywall { }

extension Stored {

  @StorageKey("paywallcription.session.isPremium", defaultValue: false)
  static var isPremium: Bool

}

//// MARK: - Intent
//
//public extension Paywall {
//
//  enum Product: Equatable, CaseIterable {
//
//    /// yearly - no trial
//    case yearly
//    /// monthly - comes with 3 days trial
//    case monthly
//
//    var id: String {
//      switch self {
//      case .yearly: return "com.appstea.proto.1y"
//      case .monthly: return "com.appstea.proto.1m"
//      }
//    }
//  }
//
//}

// MARK: - Source

public extension Paywall {

  enum Source: Equatable {
    case onboarding
    case bottomUpsell
#if DEBUG
    case debug
#endif
  }

}

// MARK: - Context

public extension Paywall {

  struct Context {
    public var sessionNumber: Int
  }

}
