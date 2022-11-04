//
//  Paywall~VC.swift
//  PaywallTemplate
//
//  Created by dDomovoj on 6/9/22.
//

import UIKit

import StoreKit
import SafariServices

import RevenueCat

import UIBase
import PaywallCraftResources

extension Paywall {

  @objc(PaywallViewController)
  open class ViewController: UIBase.ViewController {

    public let config: Config
    public let screen: Screen
    public let source: Source

    private var onClose: ((UIViewController) -> Void)?
    private var continuation: CheckedContinuation<Void, Never>?

    // MARK: - Readonly

    var analytics: Analytics.Service? { .shared }
    var paywall: Paywall.Service? { .shared }

    // MARK: - Init

    public init(config: Config, source: Source, screen: Screen, onClose: ((UIViewController) -> Void)? = nil) {
      self.config = config
      self.source = source
      self.screen = screen
      self.onClose = onClose
      super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override open func viewDidLoad() {
      super.viewDidLoad()
      Notification.Paywall.Update
        .observe { [weak self] in self?.didUpdatePaywallStatus() }
        .bind(to: self)
      analytics?.sendPaywallEvent(.upsellShown(source: source, screen: screen))
    }

    open func didUpdatePaywallStatus() { }

    // MARK: - Public

    @MainActor
    open func result() async {
      await withCheckedContinuation { c in
        continuation = c
      }
    }

    open func close() {
      onClose?(self)
      continuation?.resume(returning: ())
      continuation = nil
    }

    public func purchase(_ product: StoreProduct?) {
      if let product = product {
        analytics?.sendPaywallEvent(
          .productSelected(source: source, screen: screen, productId: product.productIdentifier))

        paywall?.purchase(product, screen: screen, source: source) { [weak self] success in
          if success {
            self?.close()
          }
          else {
            self?.checkInternetError()
          }
        }
      }
      else {
        checkInternetError()
      }
    }

    public func showTerms() {
      guard let url = NSURL(string: config.paywall.urls.terms) else { return }

      let safariVC = SFSafariViewController(url: url as URL)
      safariVC.delegate = self
      present(safariVC, animated: true)
    }

    public func showPolicy() {
      guard let url = NSURL(string: config.paywall.urls.policy) else { return }

      let safariVC = SFSafariViewController(url: url as URL)
      safariVC.delegate = self
      present(safariVC, animated: true)
    }

    public func restorePurchases() {
      paywall?.restore { [weak self] success in
        switch success {
        case .success:
          self?.close()
        case .error:
          self?.checkInternetError()
        case .noProducts:
          UIService.shared?.showAlert(title: "", message: L10n.Settings.RestoreFail.subtitle)
        }
      }
    }

  }
}

// MARK: - SFSafariViewControllerDelegate

extension Paywall.ViewController: SFSafariViewControllerDelegate {

  public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true)
  }

}

// MARK: - Private

private extension Paywall.ViewController {

  func checkInternetError() {
    if UIService.shared?.checkInternetConnection() == true {
      UIService.shared?.showAlert(title: "", message: L10n.Settings.RestoreFail.subtitle)
    }
    else {
      UIService.shared?.showAlert(title: L10n.NoInternet.title, message: L10n.NoInternet.subtitle)
    }
  }

}