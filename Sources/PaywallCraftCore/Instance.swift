//
//  Instance.swift
//
//  Created by dDomovoj on 6/22/22.
//

import UIKit

import Cascade
import Stored
import CallbacksCraft

import PaywallCraftUI

#if targetEnvironment(macCatalyst)
let isCatalyst = true
#else
let isCatalyst = false
#endif
let isMacDesignedForPad = ProcessInfo.processInfo.isiOSAppOnMac

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
  public var didPassPermissions: Bool { Stored.didPassPrepermission }
  
  public enum Event {
    case products
    case status
  }
  public let eventsObserver = GenericCallbacks<Event, Void>()

  private let config: Config
  private var keyWindow: UIWindow {
    guard let w = UIService.shared?.window
    else { preconditionFailure("Key window not assigned") }
    return w
  }

  // MARK: - Init

  public required init(config: Config) {
    self.config = config
    Analytics.Service.shared = .init(config: config)
    Paywall.Service.shared = .init(config: config)
    super.init()
    subscribeOnPaywallEvents()
  }

  // MARK: - Public
  
  @MainActor
  public func assignKeyWindow(_ window: UIWindow) {
    UIService.shared?.window = window
  }

  @MainActor
  public func showPermissions() async {
    let window = keyWindow
    let vc = Permissions.ViewController()
    if let vm = config.ui.permissions {
      vc.viewModel = vm
    }
    window.rootViewController = vc
    window.makeKeyAndVisible()
    await vc.result()
  }

  @MainActor
  public func showOnboardingPaywall() async {
    let window = keyWindow
    guard let paywall = Paywall.Service.shared, !paywall.isPremium
    else {
      return
    }

    guard let vc = Paywall.Service.shared?.paywallScreen(
      source: Paywall.Source.onboarding,
      screen: Paywall.Screen.initial
    )
    else { return }
    
    window.rootViewController = vc
    window.makeKeyAndVisible()

    for await _ in vc.events() { }
  }

  @MainActor
  public func checkATT() async {
    await UIService.shared?.checkIDFAAccessIfNeeded()
  }
  
  // MARK: Paywall screens

  @MainActor
  public func upsell(source: some IPaywallSource, screen: some IPaywallScreen,
                     from presenter: @escaping @autoclosure () -> UIViewController,
                     onEvents: Paywall.OnEvents? = nil) -> UpsellView {
    UpsellBuilder(config: config.ui.upsell) {
      UpsellBuilder.ShowCtx(source: source, screen: screen,
                            presenter: presenter(), onEvents: onEvents)
    }.build()
  }
  
  public func showPaywall(source: some IPaywallSource, screen: some IPaywallScreen,
                          from presenter: UIViewController? = nil,
                          onEvents: Paywall.OnEvents? = nil) {
    Paywall.Service.shared?.showPaywall(source: source, screen: screen,
                                        from: presenter, onEvents: onEvents)
  }
  
  @MainActor
  public func paywallScreen(source: some IPaywallSource, screen: some IPaywallScreen,
                            onEvents: Paywall.OnEvents? = nil) -> Paywall.ViewController? {
    Paywall.Service.shared?.paywallScreen(source: source, screen: screen, onEvents: onEvents)
  }

}

// MARK: - Private

private extension Instance {
  
  func subscribeOnPaywallEvents() {
    Notification.Paywall.Update.observe(on: .main) { [weak self] e in
      switch e {
      case .products: self?.eventsObserver(.products)
      case .status: self?.eventsObserver(.status)
      }
    }.bind(to: self)
  }
  
}
