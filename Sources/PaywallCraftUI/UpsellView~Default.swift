//
//  UpsellView~Default.swift
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import PinLayout

import UIBase
import UICommon
import PaywallCraftResources

public extension VM {
  
  struct UpsellDefault: IViewModel {
    
    fileprivate(set) internal var contentPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    public func contentPadding(_ v: UIEdgeInsets) -> Self {
      var c = self; c.contentPadding = v; return self
    }
    
    fileprivate(set) internal var titlePadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    public func titlePadding(_ v: UIEdgeInsets) -> Self {
      var c = self; c.titlePadding = v; return self
    }
    
    fileprivate(set) internal var title = VM.Label()
      .text(VM.Text(L10n.DefaultUpsell.title)
        .textColor(.black)
        .dynamicFont(.systemFont(ofSize: 16, weight: .medium)))
      .numberOfLines(2)
      .adjustsFontSize(.minScale(isPad ? 0.5 : 0.75))
    public func title(_ t: VM.Label.Transform) -> Self {
      var c = self; c.title.transform(using: t); return c
    }
    
    fileprivate(set) internal var cta = VM.UpsellDefault.CTA()
    public func cta(_ t: VM.UpsellDefault.CTA.Transform) -> Self {
      var c = self; c.cta.transform(using: t); return c
    }
    
//    fileprivate(set) internal var upgradeTitle = VM.Label()
//      .text(VM.Text(L10n.DefaultUpsell.Upgrade.title)
//        .dynamicFont(DynamicFont.medium(of: 16).maxSize(to: 22))
//        .textColor(.black))
//    public func upgradeTitle(_ t: VM.Label.Transform) -> Self {
//      var c = self; c.upgradeTitle.transform(using: t); return c
//    }
//
//    fileprivate(set) internal var updgradeCTA = VM.View()
//      .backgroundColor(Color.Upsell.cta.color)
//      .cornerRadius(13)
//    public func updgradeCTA(_ t: VM.View.Transform) -> Self {
//      var c = self; c.updgradeCTA.transform(using: t); return c
//    }
    
    fileprivate(set) internal var icon = VM.Image(Asset.Upsell.icon.image)
      .size(.value(CGSize(width: 35, height: 35)))
    public func icon(_ t: VM.Image.Transform) -> Self {
      var c = self; c.icon.transform(using: t); return c
    }

    fileprivate(set) internal var background = VM.View().backgroundColor(.clear)
    public func background(_ t: VM.View.Transform) -> Self {
      var c = self; c.background.transform(using: t); return c
    }
    
    public init() { }
  }
  
}

public extension UpsellView {

  final class DefaultView: UIBase.View {
    
    public typealias ViewModel = VM.UpsellDefault

    private enum Const {
      static let upgradeViewHeight: CGFloat = 26
      static let upgradeLabelOffset: CGFloat = 10
    }
    
    private var vm = ViewModel()

    // MARK: UI

    fileprivate lazy var titleLabel = UIBase.Label()
    fileprivate lazy var ctaButton = CTAButton()
    fileprivate lazy var iconView = UIBase.ImageView()
    
    // MARK: - Lifecycle

    public override func setup() {
      super.setup()
      [
        iconView,
        ctaButton,
        titleLabel
      ].forEach { addSubview($0) }
      apply(vm)
    }
    
    public func apply(_ vm: ViewModel) {
      self.vm = vm
      (self as UIView).apply(vm.background)
      
      titleLabel.apply(vm.title)
//      upgradeLabel.apply(vm.upgradeTitle)
      ctaButton.apply(vm.cta)
      iconView.apply(vm.icon)
      setNeedsLayout()
    }

    public override func layoutSubviews() {
      super.layoutSubviews()
      iconView.pin
        .start(vm.contentPadding.left).size(vm.icon.calculateSize())
        .vCenter()

      ctaButton.pin.vCenter()
        .end(vm.contentPadding.right)
        .sizeToFit()
//      let w = upgradeLabel.sizeThatFits(bounds.size).width
//      ctaButton.pin.vCenter()
//        .end(vm.contentPadding.right)
//        .height(Const.upgradeViewHeight)
//        .width(w + Const.upgradeLabelOffset * 2.0)
//
//      upgradeLabel.pin.vCenter().horizontally(Const.upgradeLabelOffset)
//        .sizeToFit(.width)

      titleLabel.pin
        .top(to: iconView.edge.top)
        .bottom(to: iconView.edge.bottom)
        .start(to: iconView.edge.end).marginStart(vm.titlePadding.left)
        .end(to: ctaButton.edge.start).marginEnd(-vm.titlePadding.right)
    }

  }
}

// MARK: - CTAButton

public extension VM.UpsellDefault {
  
  struct CTA: IViewModel {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Accessors
    
    fileprivate var height = CGFloat(26)
    public func height(_ v: CGFloat) -> Self {
      var c = self; c.height = v; return c
    }
    
    fileprivate var textPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    public func textPadding(_ v: UIEdgeInsets) -> Self {
      var c = self; c.textPadding = v; return c
    }
    
    fileprivate var text = VM.Text(L10n.DefaultUpsell.Upgrade.title)
      .dynamicFont(DynamicFont.medium(of: 16).maxSize(to: 22))
      .textColor(.black)
    public func text(_ t: VM.Text.Transform) -> Self {
      var c = self; c.text.transform(using: t); return c
    }
    
    fileprivate var background = VM.View()
      .backgroundColor(Color.Upsell.cta.color)
      .cornerRadius(13)
    public func background(_ t: VM.View.Transform) -> Self {
      var c = self; c.background.transform(using: t); return c
    }
        
  }
}

private final class CTAButton: UIBase.View {
  
  typealias ViewModel = VM.UpsellDefault.CTA
  
  private let background = UIBase.View()
  private let label = UIBase.Label {
    $0.setContentCompressionResistancePriority(.required, for: .horizontal)
  }
  
  private var vm = ViewModel()
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    let textHPadding = vm.textPadding.left + vm.textPadding.right
    let textFitWidthSize = size.width - textHPadding
    let textWidth = label.sizeThatFits(CGSize(width: textFitWidthSize, height: size.height)).width
    let w = textWidth + textHPadding
    return CGSize(width: w, height: vm.height)
  }
  
  override func setup() {
    super.setup()
    addSubviews(background, label)
  }
  
  func apply(_ vm: ViewModel) {
    self.vm = vm
    background.apply(vm.background)
    label.apply(.init().text(vm.text))
    setNeedsLayout()
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    label.pin.sizeToFit().center()
    background.pin.all()
  }
  
}
