//
//  Analytics~PaywallEvent.swift
//
//  Created by dDomovoj on 12/2/20.
//  Copyright © 2022 AppsTea. All rights reserved.
//

import Foundation

import AnalyticsCraft

extension Analytics.Event {

  enum Paywall: IAnalyticsEvent {

    typealias Paywall = PaywallCraftCore.Paywall

    case upsellShown(source: Paywall.Source, screen: Paywall.Screen)
    case productSelected( source: Paywall.Source, screen: Paywall.Screen, productId: String)

    var name: String {
      switch self {
      case .upsellShown: return "Upsell Shown"
      case .productSelected: return "Product Selected"
      }
    }

     // TODO: Screen Id?
    var params: [String: Any]? {
      switch self {
      case .upsellShown(let source, let screen):
        return [
          "Screen ID": screen.value,
          "Source": source.value,
        ]
      case .productSelected(let source, let screen, let productId):
        return [
          "Screen ID": screen.value,
          "Source": source.value,
          "Product ID": productId,
        ]
      }
    }

  }
}

// MARK: - Public

extension Analytics.Service {

  func sendPaywallEvent(_ event: Analytics.Event.Paywall) { send(event) }

}

// MARK: - Paywall.Source

extension Paywall.Source: IAnalyticsValue {

  public var value: String {
    switch self {
    case .onboarding: return "Onboarding"
    case .bottomUpsell: return "Bottom Upsell"
//    case .settings: return "Settings"
//    case .sessionStart: return "Session Start"
//    case .custom(let string): return string
#if DEBUG
    case .debug: return "DEBUG"
#endif
    }
  }

}

// MARK: - Paywall.Screen

extension Paywall.Screen: IAnalyticsValue {

  public var value: String {
    switch self {
    case .initial: return "Initial"
    }
  }

}
