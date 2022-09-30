//
//  UpsellBuilder.swift
//
//  Created by dDomovoj on 6/21/22.
//

import Foundation
import UIKit

import PaywallCraftUI
import NotificationCraftSystem

public extension Config.UI {

  struct Upsell {

    public typealias Default = UpsellView.DefaultView.ViewModel
    private let `default`: UpsellView.DefaultView.ViewModel?
    private let bgColor: UIColor?

    public init(bgColor: UIColor? = nil, `default`: Default? = nil) {
      self.bgColor = bgColor
      self.default = `default`
    }

    func applyToUpsellView(to upsellView: UpsellView) {
      if let vm = `default` {
        upsellView.defaultView.viewModel = vm
      }
      if let bgColor = bgColor {
        upsellView.backgroundColor = bgColor
      }
    }

  }
}

struct UpsellBuilder {

  struct ShowCtx {
    let source: Paywall.Source
    let screen: Paywall.Screen
    let presenter: UIViewController

    public init(source: Paywall.Source, screen: Paywall.Screen, presenter: UIViewController) {
      self.source = source
      self.screen = screen
      self.presenter = presenter
    }
  }

  let config: Config.UI.Upsell?
  let showContext: () -> (ShowCtx?)

  func build() -> UpsellView {
    let result = UpsellView()
    config?.applyToUpsellView(to: result)

    result.onClick = {
      guard let ctx = showContext() else { return }

//      Paywall.Service.shared?.showPaywall(source: .bottomUpsell, intent: .normal, from: self)
      Paywall.Service.shared?.showPaywall(source: ctx.source, screen: ctx.screen, from: ctx.presenter)
    }

    addObservers(to: result)

    return result
  }

  // MARK: - Init

  init(config: Config.UI.Upsell?, showCtxProvider: @escaping () -> (ShowCtx?)) {
    self.config = config
    showContext = showCtxProvider
  }

}

// MARK: - Private

private extension UpsellBuilder {

  func addObservers(to upsellView: UpsellView) {
    [
      Notification.Paywall.Update.observe { [weak upsellView] in self.updateUpsellIfNeeded(in: upsellView) },
      Notification.System.DidBecomeActive.observe { [weak upsellView] in self.loadUpsell(in: upsellView) },
      Notification.System.DidEnterBackground.observe { [weak upsellView] in self.removeUpsell(from: upsellView) },
      Notification.System.WillResignActive.observe { [weak upsellView] in self.removeUpsell(from: upsellView) },
    ].forEach { $0.bind(to: upsellView) }

    upsellView.onMoveToSuperview.add { [weak upsellView] in
      self.updateUpsellIfNeeded(in: upsellView)
    }.bindLifetime(to: upsellView)
  }

  func updateUpsellIfNeeded(in upsellView: UpsellView?) {
    if PaywallCraftCore.Paywall.Service.shared?.isPremium == true {
      removeUpsell(from: upsellView)
    }
    else {
      loadUpsell(in: upsellView)
    }
    upsellView?.superview?.setNeedsUpdateConstraints()
    upsellView?.superview?.setNeedsLayout()
    upsellView?.superview?.layoutIfNeeded()
  }

  func loadUpsell(in upsellView: UpsellView?) {
    if PaywallCraftCore.Paywall.Service.shared?.isPremium == true { return }

//    Ads.Service.shared?.getUpsell(vc: self, loadedBlock: { [weak self] upsell in
//      self?.upsellView.setUpsell(upsell: upsell)
//    }, errorBlock: { [weak self] in
//      DispatchQueue.main.async {
//        self?.removeUpsell()
//      }
//      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//        self?.loadUpsell()
//      }
//    })
  }

  func removeUpsell(from upsellView: UpsellView?) {
    upsellView?.removeUpsell()
  }

}
