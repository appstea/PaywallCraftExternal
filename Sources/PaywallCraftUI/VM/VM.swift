//
//  VM.swift
//
//  Created by dDomovoj on 02/12/2022.
//

import Foundation

public enum VM { }
public protocol IViewModel {
  
  init()
  
}
public protocol IView {
  
  associatedtype ViewModel: IViewModel
  
  func apply(_ viewModel: ViewModel)
  
}

import UIBase

public struct UIContext {
  
  public var isPad: Bool { UIBase.isPad }
  public var isRTL: Bool { UIBase.isRTL }
  public var isLandscape: Bool { UIBase.isLandscape }
  public var uiIntent: UI.Intent { .paywall }
  
}

public extension IViewModel {
  
  typealias Transform = (Self) -> Self
  
  var ctx: UIContext { .init() }
  
  mutating func transform(using t: Transform) {
    self = t(self)
  }
  
}

public extension Optional where Wrapped: IViewModel {
  
  mutating func transform(using t: Wrapped.Transform) {
    self = t(self ?? Wrapped.init())
  }
  
}

public extension VM {
  
  
  
}
