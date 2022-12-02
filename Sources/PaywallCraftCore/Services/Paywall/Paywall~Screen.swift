//
//  Paywall~Screen.swift
//
//  Created by dDomovoj on 6/16/22.
//

import Foundation

import AnalyticsCraft

extension Paywall {

  public enum Screen { }
  
}

public protocol IPaywallScreen {
  
  var analytics: IAnalyticsValue { get }
  
}

public extension IPaywallScreen {
  
  static func == <T: IPaywallScreen>(lhs: Self, rhs: T) -> Bool { Self.self == T.self }
  static func == <T: IPaywallScreen>(lhs: T, rhs: Self) -> Bool { Self.self == T.self }
  
}

public extension Paywall.Screen {
  
  static var initial: any IPaywallScreen { Initial() }
  
}

extension Paywall.Screen {
  
  struct Initial: IPaywallScreen {
    
    public var analytics: IAnalyticsValue { "Initial".analytics() }
    
  }
  
}
