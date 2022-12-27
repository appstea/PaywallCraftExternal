//
//  Paywall~Source.swift
//
//  Created by Dzmitry Duleba on 02/12/2022.
//

import Foundation

import AnalyticsCraft

public extension Paywall {
  
  enum Source { }
  
}

public protocol IPaywallSource {
  
  var analytics: IAnalyticsValue { get }
  
}

public extension IPaywallSource {
  
  static func == <T: IPaywallSource>(lhs: Self, rhs: T) -> Bool { Self.self == T.self }
  static func == <T: IPaywallSource>(lhs: T, rhs: Self) -> Bool { Self.self == T.self }
  
}

public extension Paywall.Source {
  
  static var onboarding: any IPaywallSource { Onboarding() }
  static var `default`: any IPaywallSource { Default() }
  static var bottomUpsell: any IPaywallSource { BottomUpsell() }
  #if DEBUG
  static var debug: any IPaywallSource { Debug() }
  #endif
  
}

extension Paywall.Source {
  
  struct Onboarding: IPaywallSource {
    public var analytics: IAnalyticsValue { "Onboarding".analytics() }
  }
  
  struct Default: IPaywallSource {
    public var analytics: IAnalyticsValue { "Default".analytics() }
  }
  
  struct BottomUpsell: IPaywallSource {
    public var analytics: IAnalyticsValue { "Bottom Upsell".analytics() }
  }
  
#if DEBUG
  struct Debug: IPaywallSource {
    public var analytics: IAnalyticsValue { "DEBUG".analytics() }
  }
#endif
  
}
