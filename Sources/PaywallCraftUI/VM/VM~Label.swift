//
//  VM~Label.swift
//
//  Created by dDomovoj on 02/12/2022.
//

import Foundation
import UIKit

public extension VM {
  
  @dynamicMemberLookup
  struct Label: IViewModel {
    
    public init() {}
    
    // MARK: - Accessors
    
    fileprivate(set) public var text: Text?
    public func text(_ v: Text) -> Self {
      var c = self; c.text = v; return c
    }
    public func text(_ t: Text.Transform) -> Self {
      var c = self; c.text.transform(using: t); return c
    }
    
    fileprivate(set) public var numberOfLines = 1
    public func numberOfLines(_ v: Int) -> Self { var c = self; c.numberOfLines = v; return c }
    
    public enum FontSizeAdjustment {
      case none
      case minScale(CGFloat)
    }
    fileprivate(set) public var adjustsFontSize = FontSizeAdjustment.none
    public func adjustsFontSize(_ v: FontSizeAdjustment) -> Self { var c = self; c.adjustsFontSize = v; return c }
    
    fileprivate(set) public var view = VM.View()
    public func view(_ t: VM.View.Transform) -> Self {
      var c = self; c.view = t(c.view); return c
    }
    public subscript<T>(dynamicMember keyPath: KeyPath<VM.View, T>) -> T { view[keyPath: keyPath] }
    
  }
}

import UIBase

extension UIBase.Label {
  
  public typealias ViewModel = VM.Label
  
  public func apply(_ viewModel: VM.Label) {
    (self as UIView).apply(viewModel.view)
    
    switch viewModel.text?._internal {
    case .string(let info):
      text = info.string
      font = info.font
      textColor = info.textColor
      adjustsFontForContentSizeCategory = info.adjustsFontForContentSizeCategory
    case .attributed(let attributedText):
      self.attributedText = attributedText
    case .none:
      text = nil
    }
    numberOfLines = viewModel.numberOfLines
    
    switch viewModel.adjustsFontSize {
    case .none:
      minimumScaleFactor = 0
      adjustsFontSizeToFitWidth = false
    case .minScale(let scale):
      minimumScaleFactor = scale
      adjustsFontSizeToFitWidth = true
    }
  }
  
}
