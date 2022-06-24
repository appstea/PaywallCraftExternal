//
//  Analytics~SubsEvent.swift
//
//  Created by dDomovoj on 12/2/20.
//  Copyright © 2022 AppsTea. All rights reserved.
//

import Foundation

import AnalyticsCraft

extension Analytics.Event {

  enum Subs: IAnalyticsEvent {

    typealias Subs = SubsCraftCore.Subs

    case upsellShown(source: Subs.Source, screen: Subs.Screen)
    case productSelected( source: Subs.Source, screen: Subs.Screen, productId: String)

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

  func sendSubsEvent(_ event: Analytics.Event.Subs) { send(event) }

}

// MARK: - Subs.Source

extension Subs.Source: IAnalyticsValue {

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

// MARK: - Subs.Screen

extension Subs.Screen: IAnalyticsValue {

  public var value: String {
    switch self {
    case .initial: return "Initial"
    }
  }

}
