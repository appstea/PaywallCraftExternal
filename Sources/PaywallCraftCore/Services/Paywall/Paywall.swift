//
//  Paywall.swift
//
//  Created by dDomovoj on 6/14/22.
//

import Foundation

import Stored

public enum Paywall { }

extension Stored {

  @StorageKey("paywall.session.isPremium", defaultValue: false)
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

// MARK: - Error

public extension Paywall {
  
  enum Error: Swift.Error, Hashable {
    case noInternet
    case productNotSpecified
    case restorationFailed
    case unknown
  }
  
}

// MARK: - Result

public extension Paywall {
  
  struct Event: CustomStringConvertible {
    public let isPremium: Bool
    public private(set) var restored: Set<String> = []
    public private(set) var purchased: Set<String> = []
    public private(set) var errors: Set<Paywall.Error> = []
    
    private var _isFinal = false
    public var isFinal: Bool {
      // implicitly marked as final
      if _isFinal { return true }
      
      // on close or continue
      if restored.isEmpty && purchased.isEmpty && errors.isEmpty { return true }
      
      // on purchase or restoration
      return !restored.isEmpty || !purchased.isEmpty
    }
    
    // MARK: - Init
    
    internal init(isPremium: Bool) {
      self.isPremium = isPremium
    }
    
    // MARK: - Public
    
    public mutating func didRestoreProduct(with id: String) { restored.insert(id) }
    public mutating func didPurchaseProduct(with id: String) { purchased.insert(id) }
    public mutating func didReceiveError(_ e: Paywall.Error) { errors.insert(e) }
    public mutating func makeFinal() { _isFinal = true }
    
    public var description: String {
      var s = "Paywall \(type(of: self)):\n-isPremium: \(isPremium)\n-isFinal: \(isFinal)"
      if _isFinal { s = s + " (implicitly)" }
      if !restored.isEmpty { s = s + "\n-restored: \(restored.sorted().joined(separator: ", "))" }
      if !purchased.isEmpty { s = s + "\n-purchased: \(purchased.sorted().joined(separator: ", "))" }
      if !errors.isEmpty { s = s + "\n-errors: \(errors.map { "\($0)" }.sorted().joined(separator: ", "))" }
      return s
    }
    
  }
  
  typealias OnEvents = (Event) -> Void
  typealias EventStream = AsyncStream<Event>
  
}

// MARK: - Context

public extension Paywall {

  struct Context {
    public var sessionNumber: Int
  }

}
