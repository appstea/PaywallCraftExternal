//
//  Instance.swift
//
//  Created by dDomovoj on 6/22/22.
//

import UIKit

import Cascade
import Stored
import PaywallCraftUI

final public class Scene: Cascade.SceneDelegate {

  fileprivate weak var instance: Instance?

  @objc
  public override func targets() -> [UISceneDelegate] {
    instance?.services.compactMap { $0 } ?? []
  }

}

final public class Instance: Cascade.AppDelegate {

  fileprivate lazy var services: [AppService?] = [
    Analytics.Service.shared,
    SessionService.current,
    FirebaseService.shared,
    UIService.shared,
    BranchService.shared,
    Paywall.Service.shared,
    NotificationService.shared,
  ]

  public private(set) lazy var scene: Scene = {
    let result = Scene()
    result.instance = self
    return result
  }()

  @objc
  public override func targets() -> [UIApplicationDelegate] {
    services.compactMap { $0 }
  }

  public var isPremium: Bool { Paywall.Service.shared?.isPremium == true }
  public var keyWindow: UIWindow? {
    get { UIService.shared?.window }
    set { UIService.shared?.window = newValue }
  }

  public var didPassPermissions: Bool { Stored.didPassPrepermission }

  private let config: Config

  // MARK: - Init

  public required init(config: Config) {
    self.config = config
    Analytics.Service.shared = .init(config: config)
    Paywall.Service.shared = .init(config: config)
  }

  // MARK: - Public

  @MainActor
  public func showPermissions(from window: UIWindow) async {
    let vc = Permissions.ViewController()
    if let vm = config.ui.permissions {
      vc.viewModel = vm
    }
    window.rootViewController = vc
    window.makeKeyAndVisible()
    await vc.result()
  }

  @MainActor
  public func showPaywall(from window: UIWindow) async {
    guard let paywall = Paywall.Service.shared, !paywall.isPremium
    else {
      return
    }

    HUD.show()
    let vc = await Paywall.Service.shared?.paywallScreen(source: .onboarding, screen: .initial)
    HUD.dismiss()
    window.rootViewController = vc
    window.makeKeyAndVisible()

    await vc?.result()
  }

  public func checkATT() async {
    await UIService.shared?.checkIDFAAccessIfNeeded()
  }

  public func upsell(source: Paywall.Source, screen: Paywall.Screen, presenter: UIViewController) -> UpsellView {
    UpsellBuilder(config: config.ui.upsell, showCtxProvider: { [weak presenter] in
      guard let presenter = presenter else { return nil }

      return .init(source: source, screen: screen, presenter: presenter)
    }).build()
  }

}
