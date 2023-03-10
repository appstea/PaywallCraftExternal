//
//  BranchService.swift
//
//  Created by dDomovoj on 6/14/22.
//

import Branch

final class BranchService: AppService {

  private var instance: Branch { .getInstance() }

  private var paywall: Paywall.Service? { .shared }

  // MARK: - Init

  private(set) static var shared: BranchService?
  static func prepare(using config: Config) {
    if config.analytics.isBranchEnabled {
      shared = .init()
    }
  }
  
  private override init() {
    super.init()
  }

  // MARK: - Lifecycle

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: LaunchOptions? = nil) -> Bool {
    instance.initSession(launchOptions: launchOptions) { [weak self] params, _ in
      if let params = params as? [String: Any],
         let campaign = params[BRANCH_INIT_KEY_CAMPAIGN] as? String {
        self?.paywall?.updateAttribute(.branch(.campaign(campaign)))
      }
    }
    return true
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping RestorationHandler) -> Bool {
    instance.continue(userActivity)
    return false
  }

  func application(_ app: UIApplication, open url: URL, options: OpenURLOptions = [:]) -> Bool {
    instance.application(.shared, open: url, options: options)
    return false
  }

  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: UserInfo,
                   fetchCompletionHandler completionHandler: @escaping BackgroundFetchResultHandler) {
    instance.handlePushNotification(userInfo)
  }

}
