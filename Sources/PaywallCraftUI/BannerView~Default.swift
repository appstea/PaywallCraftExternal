//
//  DefaultUpsellView.swift
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import PinLayout

import UIBase
import UICommon
import PaywallCraftResources

public extension UpsellView {

  final class DefaultView: UIBase.View {

    private enum Const {
      static let upgradeLabelFontSize: CGFloat = 16
      static let upgradeViewHeight: CGFloat = 26
      static let upgradeLabelOffset: CGFloat = 10
      static let iconSize: CGFloat = 35
      static let leftOffset: CGFloat = 5
      static let titleLeftOffset: CGFloat = 10
    }

    public struct ViewModel {
      
      public var title = VM.Label(
        VM.Text(L10n.DefaultUpsell.title)
          .textColor(.black)
          .dynamicFont(.systemFont(ofSize: Const.upgradeLabelFontSize, weight: .medium))
      )
        .numberOfLines(2)
        .adjustsFontSize(.minScale(isPad ? 0.5 : 0.75))

      public var upgradeTitle = L10n.DefaultUpsell.Upgrade.title
      public var upgradeTextColor = UIColor.black
      public var upgradeBackgroundColor = Color.Upsell.cta.color

      public var icon = Asset.Upsell.icon.image

      public init() { }

      fileprivate func apply(to view: DefaultView) {
        view.titleLabel.apply(title)

        view.upgradeLabel.text = upgradeTitle
        view.upgradeLabel.textColor = upgradeTextColor
        view.ctaButton.backgroundColor = upgradeBackgroundColor

        view.iconView.image = icon
      }

    }
    public var viewModel = ViewModel() {
      didSet { viewModel.apply(to: self) }
    }

    // MARK: UI

    fileprivate lazy var titleLabel = UIBase.Label()
    fileprivate let ctaButton = UIBase.View {
      $0.layer.cornerRadius = Const.upgradeViewHeight / 2
    }
    fileprivate lazy var upgradeLabel = UIBase.Label {
      $0.setContentCompressionResistancePriority(.required, for: .horizontal)
      $0.dynamicFont = DynamicFont.medium(of: Const.upgradeLabelFontSize).maxSize(to: 22)
    }
    fileprivate lazy var iconView = UIBase.ImageView()

    // MARK: - Lifecycle

    public override func setup() {
      super.setup()
      backgroundColor = .clear
      [
        iconView,
        ctaButton,
        titleLabel
      ].forEach { addSubview($0) }
      ctaButton.addSubview(upgradeLabel)
      viewModel.apply(to: self)
    }

    public override func layoutSubviews() {
      super.layoutSubviews()
      iconView.pin
        .start(Const.leftOffset).size(Const.iconSize)
        .vCenter()

      let w = upgradeLabel.sizeThatFits(bounds.size).width
      ctaButton.pin.vCenter()
        .end(Const.leftOffset)
        .height(Const.upgradeViewHeight)
        .width(w + Const.upgradeLabelOffset * 2.0)

      upgradeLabel.pin.vCenter().horizontally(Const.upgradeLabelOffset)
        .sizeToFit(.width)

      titleLabel.pin
        .top(to: iconView.edge.top)
        .bottom(to: iconView.edge.bottom)
        .start(to: iconView.edge.end).marginStart(Const.titleLeftOffset)
        .end(to: ctaButton.edge.start).marginEnd(-Const.titleLeftOffset)
    }

  }
}

// MARK: - VM

public protocol IViewModel { }
public protocol IView {
  
  associatedtype ViewModel: IViewModel
  
  func apply(_ viewModel: ViewModel)
  
}

//public extension IViewModel {
//  
//  var ctx: UIContext { .init() }
//  
//}

public enum VM { }

public extension VM {
  
  struct Text {
    fileprivate enum Internal {
      fileprivate struct StringText {
        var string: String
        var font: UIFont?
        var textColor: UIColor?
        var adjustsFontForContentSizeCategory = false
        
        init(_ string: String) { self.string = string }
      }
      case string(StringText)
      case attributed(NSAttributedString)
    }
    fileprivate var _internal: Internal
    
    public init(_ string: String) { _internal = .string(.init(string)) }
    public init(_ attributedString: NSAttributedString) { _internal = .attributed(attributedString) }
    
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
  
  struct Label: IViewModel {
    var text: Text
    var numberOfLines = 1
    var adjustsFontSize = FontSizeAdjustment.none
    
    public init(_ text: Text) { self.text = text }
    
    public func numberOfLines(_ v: Int) -> Self { var c = self; c.numberOfLines = v; return c }
    
    public enum FontSizeAdjustment {
      case none
      case minScale(CGFloat)
    }
    public func adjustsFontSize(_ v: FontSizeAdjustment) -> Self { var c = self; c.adjustsFontSize = v; return c }
  }
}

extension UIBase.Label: IView {
  
  public typealias ViewModel = VM.Label
  
  public func apply(_ viewModel: VM.Label) {
    switch viewModel.text._internal {
    case .string(let info):
      text = info.string
      font = info.font
      textColor = info.textColor
      adjustsFontForContentSizeCategory = info.adjustsFontForContentSizeCategory
    case .attributed(let attributedText):
      self.attributedText = attributedText
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
