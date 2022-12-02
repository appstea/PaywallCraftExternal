//
//  VM~Text.swift
//
//  Created by dDomovoj on 02/12/2022.
//

import Foundation
import UIKit

import UIBase
import struct UICommon.DynamicFont

public extension VM {
  
  struct Text: IViewModel {
    internal enum Internal {
      internal struct StringText {
        var string: String
        var font: UIFont?
        var textColor: UIColor?
        var adjustsFontForContentSizeCategory = false
        
        init(_ string: String) { self.string = string }
      }
      case string(StringText)
      case attributed(NSAttributedString)
    }
    internal var _internal: Internal
    
    public init() { _internal = .string(.init("")) }
    public init(_ string: String) { _internal = .string(.init(string)) }
    public init(_ attributedString: NSAttributedString) { _internal = .attributed(attributedString) }
    
    public func string(_ v: String) -> Self {
      guard case .string(var s) = _internal else { return self }
      
      var c = self
      s.string = v
      c._internal = .string(s)
      return c
    }
    
    public func textColor(_ v: UIColor) -> Self {
      guard case .string(var s) = _internal else { return self }
      
      var c = self
      s.textColor = v
      c._internal = .string(s)
      return c
    }
    
    public func font(_ v: UIFont) -> Self {
      guard case .string(var s) = _internal else { return self }
      
      var c = self
      s.font = v
      c._internal = .string(s)
      return c
    }
    
    public func dynamicFont(_ v: UIFont, maximumPointSize: CGFloat? = nil) -> Self {
      guard case .string(var s) = _internal else { return self }
      
      var c = self
      s.font = UIFontMetrics(forTextStyle: .body)
        .scaledFont(for: v, maximumPointSize: maximumPointSize ?? .greatestFiniteMagnitude)
      s.adjustsFontForContentSizeCategory = true
      c._internal = .string(s)
      return c
    }
    
    public func dynamicFont(_ v: DynamicFont) -> Self {
      guard case .string(var s) = _internal else { return self }
      
      var c = self
      s.font = v.asFont()
      s.adjustsFontForContentSizeCategory = true
      c._internal = .string(s)
      return c
    }
        
  }
  
}
