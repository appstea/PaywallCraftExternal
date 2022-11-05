//
//  PermissionService~Notifications.swift
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

extension PermissionService {
  
  final class Notifications: AppService {
    
    var notificationCenter: UNUserNotificationCenter { .current() }
    
    private var status: Status?
    private var requestContinuations: [CheckedContinuation<Status, Never>] = []
    private var fetchContinuations: [CheckedContinuation<Bool, Never>] = []
    
    static let shared: Notifications? = Notifications()
    private override init() {
      super.init()
    }
    
    // MARK: - Lifecycle
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      application.applicationIconBadgeNumber = 0
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - Public
    
    enum Status {
      case silent
      case allowed
      case denied
      case custom
    }
    func fetchStatusAndRequestIfNeeded() async -> Status {
      if let status = status {
        return status
      }
      
      return await withCheckedContinuation { [weak self] c in
        guard let self = self else { return }
        
        if let status = self.status {
          c.resume(returning: status)
          return
        }
        
        let shouldRequest = self.requestContinuations.isEmpty
        self.requestContinuations.append(c)
        if shouldRequest {
          requestAuthorization()
        }
      }
    }
    
    func fetchAuthorizationStatus() async -> Bool {
      if let status = status {
        return status.isAny(of: .allowed, .custom, .silent)
      }
      
      return await withCheckedContinuation { [weak self] c in
        guard let self = self else { return }
        
        if let status = self.status {
          c.resume(returning: status.isAny(of: .allowed, .custom, .silent))
          return
        }
        
        let shouldRequest = self.fetchContinuations.isEmpty
        self.fetchContinuations.append(c)
        if shouldRequest {
          fetchAuthorizationStatus()
        }
      }
    }
    
  }
}

// MARK: - Private

private extension PermissionService.Notifications {
  
  func resumeRequestContinuations(_ status: Status) {
    self.status = status
    requestContinuations.forEach {
      $0.resume(returning: status)
    }
    requestContinuations.removeAll()
  }
  
  func resumeAutorizationContinuations(_ isAuthorized: Bool) {
    fetchContinuations.forEach {
      $0.resume(returning: isAuthorized)
    }
    fetchContinuations.removeAll()
  }
  
  func requestAuthorization() {
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UIApplication.shared.applicationIconBadgeNumber = 0
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { [weak self] success, _ in
      guard success else {
        self?.resumeRequestContinuations(.denied)
        return
      }
      
      DispatchQueue.main.async {
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
          if settings.soundSetting == .disabled && settings.badgeSetting == .disabled &&
              settings.alertSetting == .disabled && settings.lockScreenSetting == .disabled &&
              settings.alertStyle == .none {
            self?.resumeRequestContinuations(.silent)
          }
          else if settings.soundSetting == .enabled && settings.badgeSetting == .enabled &&
                    settings.alertSetting == .enabled && settings.lockScreenSetting == .enabled &&
                    settings.alertStyle != .none {
            self?.resumeRequestContinuations(.allowed)
          }
          else {
            self?.resumeRequestContinuations(.custom)
          }
        }
      }
    }
  }
  
  func fetchAuthorizationStatus() {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      var isAuthorized = settings.authorizationStatus.isAny(of: .authorized, .provisional)
      if #available(iOS 14.0, *) {
        isAuthorized = settings.authorizationStatus == .ephemeral || isAuthorized
      }
      self?.resumeAutorizationContinuations(isAuthorized)
    }
  }
  
}
