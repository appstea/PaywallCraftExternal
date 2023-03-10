//
//  _Foundation~Extensions.swift
//
//  Created by dDomovoj on 6/22/22.
//

import Foundation

extension FloatingPoint {
 
  /// linear interpolation equals to: ```s + (d - s) * t```
  static func lerp(_ s: Self, _ d: Self, _ t: Self) -> Self { s + (d - s) * t }
  
  func normalized(by range: ClosedRange<Self>) -> Self {
    let length = range.upperBound - range.lowerBound
    if length <= .zero { return .zero }
    
    let val = (self - range.lowerBound) / length
    return val
  }
  
}

extension Equatable {

  /// makes use of enumCase1.isAny(of: .enumCase1, .enumCase2) available
  func isAny(of candidates: Self...) -> Bool {
    candidates.contains(self)
  }
}

extension Optional where Wrapped: Equatable {

  /// makes use of optionalEnumCase1.isAny(of: .enumCase1, .enumCase2) available
  func isAny(of candidates: Wrapped...) -> Bool {
    map { candidates.contains($0) } ?? false
  }
}

extension OptionSet {

  func containsAny(of members: Element...) -> Bool {
    members.contains(where: { self.contains($0) })
  }

}

