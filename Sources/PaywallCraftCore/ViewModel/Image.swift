//
//  Image.swift
//
//  Created by Dzmitry Duleba on 08/11/2022.
//

import Foundation
import UIKit

import UIBase

public struct UIContext {
  
  public var isPad: Bool { UIBase.isPad }
  public var isRTL: Bool { UIBase.isRTL }
  public var isLandscape: Bool { UIBase.isLandscape }
  public var uiIntent: UI.Intent { .paywall }
  
}

public struct Image {
  
  public var uiImage: UIImage
  public internal(set) var containerSize: CGSize = .zero
  
  public enum Size {
    case image
    case value(CGSize)
    case computed((Image) -> CGSize)
  }
  public var size: Size
  
  public var ctx: UIContext { .init() }
  public var aspectRatio: CGFloat { uiImage.size.aspectRatio }
  
  internal func calculateSize() -> CGSize {
    switch size {
    case .value(let size): return size
    case .computed(let calculator): return calculator(self)
    case .image: return uiImage.size
    }
  }
  
  init(_ image: UIImage, size: ((Image) -> CGSize)? = nil) {
    uiImage = image
    self.size = size.flatMap { .computed($0) } ?? .image
  }
  
}
