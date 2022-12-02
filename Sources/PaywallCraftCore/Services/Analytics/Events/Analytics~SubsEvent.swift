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

    case upsellShown(source: any IPaywallSource, screen: any IPaywallScreen)
    case productSelected( source: any IPaywallSource, screen: any IPaywallScreen, productId: String)

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
          "Screen ID": screen.analytics.value,
          "Source": source.analytics.value,
        ]
      case .productSelected(let source, let screen, let productId):
        return [
          "Screen ID": screen.analytics.value,
          "Source": source.analytics.value,
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
