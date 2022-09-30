//
//  Config.swift
//
//  Created by dDomovoj on 6/23/22.
//

import Foundation
import UIKit

public struct Config {

  let paywall: Paywall
  let analytics: Analytics
  let ui: UI

  public init(paywall: Paywall, analytics: Analytics? = nil, ui: UI? = nil) {
    self.paywall = paywall
    self.analytics = analytics ?? Analytics()
    self.ui = ui ?? UI()
  }

}

// MARK: - UI

public extension Config {

  struct UI {
    let permissions: Permissions?
    let paywallcription: Paywallcription?
    let upsell: Upsell?

    public init(
      permissions: Permissions? = nil,
      paywallcription: Paywallcription? = nil,
      upsell: Upsell? = nil
    ) {
      self.permissions = permissions
      self.paywallcription = paywallcription
      self.upsell = upsell
    }
  }

}
