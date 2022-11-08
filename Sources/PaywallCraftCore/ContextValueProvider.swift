//
//  UIValueProvider.swift
//
//  Created by Dzmitry Duleba on 08/11/2022.
//

import UIKit

public final class ContextValueProvider<C, V> {
  
  public typealias Context = C
  public typealias Value = V
  
  var ctx: Context
  private let valueProvider: (Context) -> Value
  
  public init(ctx: Context, value: @escaping (Context) -> Value) {
    self.ctx = ctx
    valueProvider = value
  }
  
  public func callAsFunction() -> Value { valueProvider(ctx) }
  
}

import Foundation
import UIBase

public struct UIContext {
  
  public var isPad: Bool { UIBase.isPad }
  public var isRTL: Bool { UIBase.isRTL }
  public var isLandscape: Bool { UIBase.isLandscape }
  public var uiIntent: UI.Intent { .paywall }
  
}

//struct UIValueProvider<T> {
//
//  struct Context {
//    let isLandscape: Bool
//    let containerSize: CGSize
//  }
//
//  private let provider: ContextValueProvider<Context, T>
//
//  init(valueProvider: @escaping (Context) -> T,
//       ctxProvider: @escaping () -> Context) {
//    provider = .init(valueProvider: valueProvider, ctxProvider: ctxProvider)
//  }
//
//}
