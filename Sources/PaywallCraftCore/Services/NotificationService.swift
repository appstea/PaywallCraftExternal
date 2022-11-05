//
//  NotificationService.swift
//
//  Created by dDomovoj on 6/14/22.
//

import Foundation
import NotificationCenter

import Stored

extension Stored {
  
  @StorageKey("paywall.notifications.enabled", defaultValue: true)
  static var isNotificationsEnabled: Bool
  
}

final class NotificationService: AppService {
  
  var notificationCenter: UNUserNotificationCenter { .current() }
  
  static let shared: NotificationService? = NotificationService()
  
  // MARK: - Lifecycle
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    application.applicationIconBadgeNumber = 0
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }
  
}

//// MARK: - Private
//
//private extension PermissionService.Notifications {
//
//  func setupRequestingProvider() {
//    statusRequestingProvider.provider = { sink in
//      DispatchQueue.main.async {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//      }
//
//      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//      UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, _ in
//        guard success else {
//          sink(.denied)
//          return
//        }
//
//        DispatchQueue.main.async {
//          UIApplication.shared.registerForRemoteNotifications()
//          UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.soundSetting == .disabled && settings.badgeSetting == .disabled &&
//                settings.alertSetting == .disabled && settings.lockScreenSetting == .disabled &&
//                settings.alertStyle == .none {
//              sink(.silent)
//            }
//            else if settings.soundSetting == .enabled && settings.badgeSetting == .enabled &&
//                      settings.alertSetting == .enabled && settings.lockScreenSetting == .enabled &&
//                      settings.alertStyle != .none {
//              sink(.allowed)
//            }
//            else {
//              sink(.custom)
//            }
//          }
//        }
//      }
//    }
//  }
//
//  func setupFetchingProvider() {
//    statusFetchingProvider.provider = { sink in
//      UNUserNotificationCenter.current().getNotificationSettings { settings in
//        var isAuthorized = settings.authorizationStatus.isAny(of: .authorized, .provisional)
//        if #available(iOS 14.0, *) {
//          isAuthorized = settings.authorizationStatus == .ephemeral || isAuthorized
//        }
//        sink(isAuthorized)
//      }
//    }
//  }
//
//}
