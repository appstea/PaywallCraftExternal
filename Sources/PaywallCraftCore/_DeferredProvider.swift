//
//  DeferredProvider.swift
//
//  Created by Dzmitry Duleba on 05/11/2022.
//

import Foundation

final class DeferredProvider<T> {
  
  private var value: T?
  private var continuations: [CheckedContinuation<T, Never>] = []
  
  typealias Sink = (T) -> Void
  typealias Provider = (@escaping Sink) -> Void
  
  var provider: Provider?
  
  private var _sink: Sink!
  var sink: Sink { _sink }
  
  init() {
    _sink = { [weak self] value in
      self?.value = value
      self?.continuations.forEach { $0.resume(returning: value) }
      self?.continuations.removeAll()
    }
  }
  
  func request() async -> T {
    if let value { return value }
    
    return await withCheckedContinuation { [weak self] c in
      guard let self = self else { return }
      if let value = self.value {
        c.resume(returning: value)
        return
      }
      
      let shouldRequest = self.continuations.isEmpty
      self.continuations.append(c)
      
      guard let provider = self.provider else { return }
      if shouldRequest {
        provider(self.sink)
      }
    }
  }
    
}

