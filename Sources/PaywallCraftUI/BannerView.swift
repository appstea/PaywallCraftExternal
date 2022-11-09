//
//  UpsellView.swift
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import PinLayout

import UIBase
import CallbacksCraft

public final class UpsellView: UIBase.View {

  private enum Const {
    static let upsellSize: CGSize = isPad
    ? CGSize(width: 728, height: 90)
    : CGSize(width: 320, height: 50)
  }

  private let lineView: UIBase.View = {
    let result = UIBase.View()
    result.backgroundColor = .black.withAlphaComponent(0.5)
    return result
  }()
  private var upsell: UIView?
  private let ctaButton = UIBase.Button()
  public private(set) lazy var defaultView = UpsellView.DefaultView()

  public var onClick: (() -> Void)?
  public let onMoveToSuperview = Callbacks()

  // MARK: - Lifecycle

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: size.width, height: Const.upsellSize.height)
  }
  public override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: Const.upsellSize.height)
  }

  public override func setup() {
    super.setup()
    isUserInteractionEnabled = true
    backgroundColor = .white
    clipsToBounds = true
    addSubview(defaultView)
    addSubview(lineView)
    addSubview(ctaButton)
    ctaButton.addAction { [unowned self] _ in onClick?() }
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    lineView.pin
      .top().start().end()
      .height(1.0 / UIScreen.main.scale)

    defaultView.pin.hCenter()
      .height(Const.upsellSize.height)
      .width(min(bounds.width, Const.upsellSize.width))
    if isPad {
      defaultView.pin.vCenter()
    }
    else {
      defaultView.pin.top()
    }
    ctaButton.pin.all()

    if let upsell = upsell {
      upsell.pin.hCenter().size(Const.upsellSize)
      if isPad {
        upsell.pin.vCenter()
      }
      else {
        upsell.pin.top(-1.0 / UIScreen.main.scale)
      }
    }
  }

  // MARK: - Public

  public func setUpsell(upsell: UIView) {
    self.upsell = upsell

    lineView.isHidden = true
    ctaButton.isHidden = true
    defaultView.isHidden = true

    upsell.removeFromSuperview()
    addSubview(upsell)
  }

  public func removeUpsell() {
    upsell?.removeFromSuperview()
    upsell = nil

    lineView.isHidden = false
    ctaButton.isHidden = false
    defaultView.isHidden = false
  }

}
