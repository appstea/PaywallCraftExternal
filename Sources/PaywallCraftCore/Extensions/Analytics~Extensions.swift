//
//  Analytics~Extensions.swift
//
//  Created by dDomovoj on 30/11/2022.
//

import Foundation

import AnalyticsCraft

public struct AnalyticsString: IAnalyticsValue, ExpressibleByStringLiteral {
  
  public let value: String
  
  public init(value: String) { self.value = value }
  public init(stringLiteral value: StringLiteralType) { self.value = value }
  public init(unicodeScalarLiteral value: String) { self.value = value }
  public init(extendedGraphemeClusterLiteral value: String) { self.value = value }
  
}

public extension String {
  
  func analytics() -> AnalyticsString { .init(value: self) }
  
}
