//
//  Paywall~Service.swift
//
//  Created by dDomovoj on 6/14/22.
//

import Foundation

import StoreKit
import RevenueCat
//import AdSupport
//import iAd

import RevenueCat

import Utils
import NotificationCraft

public enum RestoreResponseType {
  case products(Set<String>)
  case noProducts
  case error
}

public extension Config {

  struct Paywall {
    let apiKey: String
    let offering: String
    let isDebug: Bool

    public struct URLs {
      let policy: String
      let terms: String
//      let store: String

      public init(policy: String, terms: String) {//} store: String) {
        self.policy = policy
        self.terms = terms
//        self.store = store
      }
    }
    let urls: URLs

    public init(apiKey: String, offering: String, isDebug: Bool, urls: URLs) {
      self.apiKey = apiKey
      self.offering = offering
      self.isDebug = isDebug
      self.urls = urls
    }
  }

}

// MARK: - Paywall

extension Notification {

  enum Paywall {

    enum Update: INotification {
      typealias Data = Event
      enum Event {
        case status
        case products
      }
    }

  }

}

extension Paywall {

  final class Service: AppService {

    enum Attribute {
      case idfa(String)
      case idfv(String)
      case apns(Data)
      case fcm(String)
      case fbAnonId(String)

      // swiftlint:disable:next nesting
      enum Branch {
        case mediaSource(String)
        case campaign(String)
        case adGroup(String)
        case ad(String)
        case keyword(String)
        case creative(String)
      }
      case branch(Branch)

//      case onboarding(Onboarding)
    }

    private let manager: PurchasesManager
    //
    var isPremium: Bool { manager.isPremium }
    var isDebugPremium: Bool {
      get { manager.debugPremium }
      set { manager.debugPremium = newValue }
    }

    static var shared: Paywall.Service?
    init(config: Config) {
      manager = .init(config: config)
    }

    // MARK: - Lifecycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: LaunchOptions? = nil) -> Bool {
      observeSessions()
      if let idfv = UIDevice.current.identifierForVendor {
        updateAttribute(.idfv(idfv.uuidString))
      }
      return true
    }

    private func didBecomActive() { sync() }
    func applicationDidBecomeActive(_ application: UIApplication) { didBecomActive() }
    func sceneDidBecomeActive(_ scene: UIScene) { didBecomActive() }

    private func didEnterBackground() {
      manager.hideCurrentPaywallScreen(animated: false)
    }
    func applicationDidEnterBackground(_ application: UIApplication) { didEnterBackground() }
    func sceneDidEnterBackground(_ scene: UIScene) { didEnterBackground() }

    func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      updateAttribute(.apns(deviceToken))
    }

    // MARK: - Public
    
    func createEvent() -> Paywall.Event { manager.createEvent() }

    func updateAttribute(_ attribute: Attribute) {
      let purchases = Purchases.shared
      switch attribute {
      case .apns(let data): purchases.attribution.setPushToken(data)
      case .fcm(let token): purchases.attribution.setAttributes(["$fcmTokens": token])
      case .idfa(let id): purchases.attribution.setAttributes(["$idfa": id])
      case .idfv(let id): purchases.attribution.setAttributes(["$idfv": id])
      case .fbAnonId(let id): purchases.attribution.setFBAnonymousID(id)
      case .branch(let attribute):
        switch attribute {
        case .mediaSource(let source): purchases.attribution.setMediaSource(source)
        case .campaign(let campaign): purchases.attribution.setCampaign(campaign)
        case .adGroup(let group): purchases.attribution.setAdGroup(group)
        case .ad(let id): purchases.attribution.setAd(id)
        case .keyword(let keyword): purchases.attribution.setKeyword(keyword)
        case .creative(let id): purchases.attribution.setCreative(id)
        }
      }
    }

    /// main thread-trampolined
    func showPaywall(source: some IPaywallSource, screen: some IPaywallScreen,
                     from presenter: UIViewController? = nil,
                     onEvents: Paywall.OnEvents? = nil) {
      guard let sessionIdx = SessionService.current?.currentSessionIdx else { return }
      guard Thread.isMainThread else {
        DispatchQueue.main.async { [weak self] in
          self?.showPaywall(source: source, screen: screen, from: presenter, onEvents: onEvents)
        }
        return
      }
      
      let context = Context(sessionNumber: sessionIdx)
      _showPaywallScreen(source: source, screen: screen, context: context,
                         from: presenter, onEvents: onEvents)
    }

    @MainActor
    func paywallScreen(source: some IPaywallSource, screen: some IPaywallScreen,
                       onEvents: Paywall.OnEvents? = nil) -> Paywall.ViewController {
      _paywallScreenViewController(source: source, screen: screen, onEvents: onEvents)
    }

    func sync() {
      manager.syncIfNeeded()
    }

    func restore(completion: ((RestoreResponseType) -> Void)? = nil) {
      manager.restore(block: completion)
    }

    func hasProducts() -> Bool {
      manager.hasProducts
    }

    func productsList() -> [StoreProduct] {
      manager.productsList()
    }

    func purchase(_ product: StoreProduct, screen: some IPaywallScreen,
                  source: some IPaywallSource, block: ((Bool) -> Void)? = nil) {
      manager.purchase(product: product, source: source) { result in
        switch result {
        case .purchased: block?(true)
        default: break
        }
      }
    }

  }
}

// MARK: - Private

private extension Paywall.Service {

  func observeSessions() {
//    Notification.Session.Change
//      .observe { [weak self] session in
//        guard let self = self,
//              !self.isPremium,
//              session > 0
//        else { return }
//
//        if session % $0.paywallShowSessionInterval == 0 && session != 1 {
//          self.showPaywall(source: .sessionStart, intent: .onStart)
//
//        }
//        else if (session == $0.offerShowSessionInterval || ((session - $0.offerShowSessionInterval)  % $0.offerShowSessionRepeat == 0)) && session != 1 {
//          self.showPaywall(source: .bottomUpsell, intent: .additionInstant, session: session)
//        }
//      }
//      .bind(to: self)
  }

  @MainActor
  func _showPaywallScreen(source: some IPaywallSource, screen: some IPaywallScreen,
                          context: Paywall.Context, from presenter: UIViewController? = nil,
                          onEvents: Paywall.OnEvents? = nil) {
      guard !isPremium,
            let presenter = presenter ?? UIService.shared?.presenter
      else { return }

      manager.showPaywallScreen(source: source, screen: screen, from: presenter, onEvents: onEvents)
  }

  @MainActor
  func _paywallScreenViewController(source: some IPaywallSource, screen: some IPaywallScreen,
                                    onEvents: Paywall.OnEvents? = nil) -> Paywall.ViewController {
    manager.paywallScreen(source: source, screen: screen, onEvents: onEvents)
  }

}
