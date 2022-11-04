//
//  Permissions~VC.swift
//  PaywallTemplate
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import SwiftyAttributes
import PinLayout

import StackCraft

import Utils
import Stored
import UIBase
import UICommon
import PaywallCraftResources

extension Stored {

  @StorageKey("paywall.didPassPrepermission", defaultValue: false)
  fileprivate(set) static var didPassPrepermission: Bool

}

public extension Config.UI {

  typealias Permissions = PaywallCraftCore.Permissions.ViewModel

}


public enum Permissions {}

extension Permissions {

  public struct ViewModel {
    public var bgColors = [
      Color.Onboarding.background.color.withAlphaComponent(0),
      Color.Onboarding.background.color.withAlphaComponent(0),
    ]
    public var image = Asset.Permissions.image.image
    public var imageSize = (isPad && isPortrait)
    ? CGSize(width: 525.ui(.paywall), height: 263.ui(.paywall))
    : CGSize(width: 375.ui(.paywall), height: 188.ui(.paywall))

    public var textColor = Color.Main.text.color
    public var dotColor = Color.DotLabel.dot.color
    public var ctaTextColor = UIColor.white
    public var ctaBgColor = Color.Onboarding.continue.color

    public var title = L10n.Permissions.title
    public var subtitle = L10n.Permissions.subtitle
    
    public struct Feature: Equatable {
      public enum FeatureType: Equatable {
        case notifications
        case location
        case photos
        case motion
      }
      public let type: FeatureType
      public let icon: UIImage
      public let title: String
      public let description: String
      
      enum Defaults {
        static let notifications = Feature(
          type: .notifications,
          icon: UIImage(),
          title: L10n.Permissions.Feature.Notifications.title,
          description: L10n.Permissions.Feature.Notifications.description
        )
        static let location = Feature(
          type: .location,
          icon: UIImage(),
          title: L10n.Permissions.Feature.Location.title,
          description: L10n.Permissions.Feature.Location.description
        )
        static let motion = Feature(
          type: .motion,
          icon: UIImage(),
          title: L10n.Permissions.Feature.MotionData.title,
          description: L10n.Permissions.Feature.MotionData.description
        )
        static let photos = Feature(
          type: .photos,
          icon: UIImage(),
          title: L10n.Permissions.Feature.Photos.title,
          description: L10n.Permissions.Feature.Photos.description
        )
      }
    }
    public var features: [Feature] = [
      Feature.Defaults.notifications,
      Feature.Defaults.location,
      Feature.Defaults.photos,
      Feature.Defaults.motion,
    ]
    public var cta = L10n.Permissions.Button.continue

    public init() {}

    fileprivate func apply(to view: ViewController) {
      view.bgView.colors = bgColors
      view.imageView.image = image

      view.titleLabel.text = title
      view.titleLabel.textColor = textColor

      view.subtitleLabel.text = subtitle
      view.subtitleLabel.textColor = textColor

      features.enumerated().forEach { idx, feature in
        let label = view.dotLabel(idx)
        label.dotColor = dotColor
        label.text = feature.title
          .withFont(DynamicFont.regular(of: isPad ? 24 : 16)
            .maxSize(to: isPad ? 40 : 28)
            .asFont())
          .withTextColor(Color.Main.text.color)
          .withParagraphStyle(NSMutableParagraphStyle {
            $0.lineSpacing = 5
            $0.alignment = isRTL ? .right : .left
          })
      }

      view.ctaButton.setTitle(cta, for: .normal)
      view.ctaButton.setTitleColor(ctaTextColor, for: .normal)
      view.ctaButton.backgroundColor = ctaBgColor

      view.reloadUI()
    }
  }

  final class ViewController: UIBase.ViewController {

    private enum Const {
      static let buttonSize = CGSize(width: isPad ? 400.ui(.paywall) : 285.ui(.paywall), height: isPad ? 70 : 50)
      static let dotSize: CGFloat = (isPad ? 18 : 13).ui(.paywall)
      static let dotSpacing = 10.ui(.paywall)
      static var contentWidth: CGFloat { (isPad && isLandscape) ? 0.6 : 0.8 }
    }

    var viewModel = ViewModel() {
      didSet { viewModel.apply(to: self) }
    }

    private var passContinuation: CheckedContinuation<Void, Never>?

    override public var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: UI

    fileprivate let bgView = UICommon.GradientView {
      $0.direction = .down
    }

    fileprivate let stackView = VStackView {
      $0.backgroundColor = .clear
    }

    fileprivate let imageView = UIBase.ImageView {
      $0.contentMode = .scaleAspectFit
    }
    fileprivate let titleLabel = UIBase.Label {
      $0.setDynamicFont(font: .systemFont(ofSize: isPad ? 30 : 20, weight: .medium),
                        maximumPointSize: isPad ? 60 : 40)
      $0.textAlignment = isRTL ? .right : .center
      $0.numberOfLines = 0
      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.8
    }
    fileprivate let subtitleLabel = UIBase.Label {
      $0.setDynamicFont(font: .systemFont(ofSize: isPad ? 24 : 16),
                        maximumPointSize: isPad ? 48 : 32)
      $0.textAlignment = isRTL ? .right : .center
      $0.numberOfLines = 0
      $0.adjustsFontSizeToFitWidth = true
      $0.minimumScaleFactor = 0.8
    }
    private static func dotLabelInstance() -> UICommon.DotLabel {
      UICommon.DotLabel {
        $0.dotSize = Const.dotSize
        $0.dotPadding = Const.dotSpacing
      }
    }
    private var dotLabelsPool = [Int: UICommon.DotLabel]()
    fileprivate func dotLabel(_ idx: Int) -> UICommon.DotLabel {
      let result = dotLabelsPool[idx] ?? UICommon.DotLabel {
        $0.dotSize = Const.dotSize
        $0.dotPadding = Const.dotSpacing
      }
      dotLabelsPool[idx] = result
      return result
    }

    fileprivate let ctaButton = UIBase.Button {
      $0.layer.cornerRadius = 12
      $0.titleLabel?.font = .systemFont(ofSize: isPad ? 30 : 20, weight: .medium)
    }.asAccessibilityElement()

    // MARK: - Lifecycle

    override func loadView() {
      super.loadView()
      view.backgroundColor = Color.Main.back.color
      view.addSubviews(bgView, stackView)
    }

    override func viewDidLoad() {
      super.viewDidLoad()
      viewModel.apply(to: self)
      view.setNeedsLayout()
      ctaButton.addAction { [weak self] _ in self?.onContinue() }
      //        reload(for: onboarding)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      super.traitCollectionDidChange(previousTraitCollection)
      viewModel.apply(to: self)
      view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

      let safeArea = view.pin.safeArea
      let contentWidth = view.bounds.width * Const.contentWidth

      if isPad && isPortrait {
        bgView.pin.top().horizontally().height(35%)
      }
      else {
        bgView.pin.top().horizontally().height(280.ui(.paywall) + safeArea.top)
      }
      stackView.pin.hCenter().width(contentWidth).vertically(safeArea)

      reloadUI()
    }

    // MARK: - Public

    func result() async {
      await withCheckedContinuation { [weak self] c in
        self?.passContinuation = c
      }
    }

    //    func reload(for onboarding: Onboarding) {
    ////        self.onboarding = onboarding
    //        UIView.transition(with: imageView, duration: 0.25, options: .transitionCrossDissolve) { [unowned self] in
    //            imageView.image = onboarding.image
    //        } completion: { _ in }
    //        view.setNeedsLayout()
    //    }

  }
}

// MARK: - Private

fileprivate extension Permissions.ViewController {

  func reloadUI() {
    stackView.reload {
      (isPad && isPortrait) ? 190.fixed : 95.fixed
      imageView.vComponent
        .size(viewModel.imageSize)
        .alignment(.center)
      isPad ? 110.fixed : 83.fixed
      titleLabel.vComponent.maxHeight(40.ui(.paywall))
      isPad ? 20.floating : 20.fixed
      subtitleLabel.vComponent.maxHeight(30.ui(.paywall))
      isPad ? 16.floating : 16.fixed

      dotLabels()
      
      isPad ? 160.floating : 20.floating
      ctaButton.vComponent
        .size(Const.buttonSize)
        .alignment(.center)
      60.fixed
    }
    
    func dotLabels() -> [VStackViewItemConvertible] {
      dotLabelsPool.keys.sorted().enumerated().flatMap { idx, key -> [VStackViewItemConvertible] in
        let label = dotLabel(key)
        var result = [any VStackViewItemConvertible]()
        if isPad {
          result.append(
            label.vComponent.maxHeight(120.ui(.paywall))
              .width(.fixed(Const.buttonSize.width))
              .alignment(.center)
          )
        }
        else {
          result.append(
            label.vComponent.maxHeight(120.ui(.paywall))
          )
        }
        
        let isLast = idx == dotLabelsPool.count - 1
        if !isLast {
          result.append(10.floating)
        }
        return result
      }
    }
    
  }
}

// MARK: - Actions

private extension Permissions.ViewController {

  func onContinue() {
    Task {
      await requestPermissions()
      Stored.didPassPrepermission = true
      passContinuation?.resume(returning: Void())
      passContinuation = nil
    }
  }

  func requestPermissions() async {
    _ = await NotificationsService.shared?.fetchStatus()
  }

}
