//
//  VM~View.swift
//
//  Created by dDomovoj on 02/12/2022.
//

import Foundation
import UIKit

public extension VM {
  
  struct View: IViewModel {
    
    public init() {}
    
    // MARK: - Accessors
    
    var backgroundColor: UIColor = .clear
    public func backgroundColor(_ v: UIColor) -> Self { var c = self; c.backgroundColor = v; return c }
    
    var cornerRadius: CGFloat = 0
    public func cornerRadius(_ v: CGFloat) -> Self { var c = self; c.cornerRadius = v; return c }
  }
  
}

import UIBase

extension UIView: IView  {
  
  public typealias ViewModel = VM.View
  
  public func apply(_ viewModel: VM.View) {
    backgroundColor = viewModel.backgroundColor
    layer.cornerRadius = viewModel.cornerRadius
  }
  
}
