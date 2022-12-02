//
//  UpsellView.swift
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import PinLayout

import UIBase
import CallbacksCraft

public extension VM {
  
  struct Upsell: IViewModel {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Accessors
    
    fileprivate(set) internal var size: CGSize = isPad
    ? CGSize(width: 728, height: 90)
    : CGSize(width: 320, height: 50)
    public func size(_ v: CGSize) -> Self {
      var c = self; c.size = v; return c
    }
    
    fileprivate(set) internal var `default`: UpsellDefault?
    public func `default`(_ t: UpsellDefault.Transform) -> Self {
      var c = self; c.default.transform(using: t); return c
    }
    
    fileprivate(set) public var background = VM.View().backgroundColor(.white)
    public func background(_ t: VM.View.Transform) -> Self {
      var c = self; c.background.transform(using: t); return c
    }
    
  }
  
}

public final class UpsellView: UIBase.View {
  
  public typealias ViewModel = VM.Upsell
  
  // MARK: UI

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
  
  private var vm = ViewModel()

  // MARK: - Lifecycle

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    CGSize(width: size.width, height: vm.size.height)
  }
  public override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: vm.size.height)
  }

  public override func setup() {
    super.setup()
    isUserInteractionEnabled = true
    clipsToBounds = true
    addSubview(defaultView)
    addSubview(lineView)
    addSubview(ctaButton)
    ctaButton.addAction { [unowned self] _ in onClick?() }
    apply(vm)
  }
  
  public func apply(_ viewModel: ViewModel) {
    (self as UIView).apply(viewModel.background)
    
    if let vm = viewModel.default {
      defaultView.apply(vm)
    }
    setNeedsLayout()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    lineView.pin
      .top().start().end()
      .height(1.0 / UIScreen.main.scale)

    defaultView.pin.hCenter()
      .height(vm.size.height)
      .width(min(bounds.width, vm.size.width))
    if isPad {
      defaultView.pin.vCenter()
    }
    else {
      defaultView.pin.top()
    }
    ctaButton.pin.all()

    if let upsell = upsell {
      upsell.pin.hCenter().size(vm.size)
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
