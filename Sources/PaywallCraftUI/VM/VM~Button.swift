//
//  VM~Button.swift
//
//  Created by Dzmitry Duleba on 02/12/2022.
//

import Foundation
import UIKit

public extension VM {
  
  @dynamicMemberLookup
  struct Button: IViewModel {
    
    public init() {}
    
    // MARK: - Accessors
    
    fileprivate(set) public var text: Text?
    public func text(_ t: Text.Transform) -> Self {
      var c = self; c.text = t(c.text ?? Text()); return c
    }
    
    fileprivate(set) public var view = VM.View()
    public func view(_ t: VM.View.Transform) -> Self {
      var c = self; c.view.transform(using: t); return c
    }
    public subscript<T>(dynamicMember keyPath: KeyPath<VM.View, T>) -> T { view[keyPath: keyPath] }
    
  }
}

import UIBase

extension UIBase.Button {
  
  public typealias ViewModel = VM.Button
  
  public func apply(_ viewModel: ViewModel) {
    (self as UIView).apply(viewModel.view)
    
    switch viewModel.text?._internal {
    case .string(let t):
      setTitle(t.string, for: .normal)
      setTitleColor(t.textColor, for: .normal)
      titleLabel?.font = t.font
      titleLabel?.adjustsFontForContentSizeCategory = t.adjustsFontForContentSizeCategory
    case .attributed(let t):
      setAttributedTitle(t, for: .normal)
    case .none:
      setTitle(nil, for: .normal)
    }
  }
  
}
