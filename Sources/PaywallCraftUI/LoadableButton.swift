//
//  LoadableButton.swift
//
//  Created by dDomovoj on 08/11/2022.
//

import UIKit

import PinLayout

import Utils
import UIBase

public final class LoadableButton: UIBase.Button {
  
  private let indicator = UIActivityIndicatorView(style: .medium).with {
    $0.hidesWhenStopped = true
  }
  
  public var indicatorColor: UIColor! {
    get { indicator.color }
    set { indicator.color = newValue }
  }
  
  public var borderColor: UIColor = .clear { didSet { layer.borderColor = borderColor.cgColor } }
  public var color: UIColor = .clear { didSet { setBackgroundImage(color.image(), for: .normal) } }
  
  // MARK: - Lifecycle
  
  public override func setup() {
    super.setup()
    color = .clear
    borderColor = .clear
    addSubview(indicator)
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    indicator.pin.center().sizeToFit()
  }
  
  // MARK: - Public
  
  public enum Content {
    case text(NSAttributedString)
    case loading
  }
  private var content: Content?
  public func setContent(_ content: Content) {
    self.content = content
    switch content {
    case .text(let text):
      setAttributedTitle(text, for: .normal)
      indicator.stopAnimating()
    case .loading:
      setTitle(nil, for: .normal)
      indicator.startAnimating()
    }
  }
  
}
