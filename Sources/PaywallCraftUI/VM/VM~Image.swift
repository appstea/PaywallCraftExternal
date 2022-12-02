//
//  VM~Image.swift
//
//  Created by dDomovoj on 08/11/2022.
//

import Foundation
import UIKit

public extension VM {
  
  @dynamicMemberLookup
  struct Image: IViewModel {
    
    public let uiImage: UIImage
    // TODO: check access
    public var containerSize: CGSize = .zero
    public var aspectRatio: CGFloat { uiImage.size.aspectRatio }
    
    // MARK: - Init
    
    public init() { uiImage = UIImage() }
    public init(_ image: UIImage) {
      uiImage = image
    }
    
    // MARK: - Accessors
    
    public enum Size {
      case image
      case value(CGSize)
      case computed((Image) -> CGSize)
    }
    fileprivate(set) public var size: Size = .image
    public func size(_ v: Size) -> Self { var c = self; c.size = v; return c }
    
    fileprivate(set) public var view = VM.View()
    public func view(_ t: VM.View.Transform) -> Self {
      var c = self; c.view.transform(using: t); return c
    }
    public subscript<T>(dynamicMember keyPath: KeyPath<VM.View, T>) -> T { view[keyPath: keyPath] }
    
    // MARK: - Public
    
    // TODO: check access
    public func calculateSize() -> CGSize {
      switch size {
      case .value(let size): return size
      case .computed(let calculator): return calculator(self)
      case .image: return uiImage.size
      }
    }
    
  }
}

import UIBase

extension UIBase.ImageView {
  
  public typealias ViewModel = VM.Image
  
  public func apply(_ viewModel: VM.Image) {
    (self as UIView).apply(viewModel.view)
    
    image = viewModel.uiImage
  }
  
}
