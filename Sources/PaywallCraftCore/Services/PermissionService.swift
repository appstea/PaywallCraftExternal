//
//  PermissionService.swift
//
//  Created by dDomovoj on 05/11/2022.
//

import Foundation

import PermissionsKit
import NotificationPermission
import PhotoLibraryPermission
import LocationAlwaysPermission
import LocationWhenInUsePermission
import MotionPermission

enum PermissionService {
  
  typealias Permission = Permissions.ViewModel.Permission.PermissionType
  typealias Status = Permissions.ViewModel.Permission.Status
  
}

// MARK: - Request Permissions

extension PermissionService {
  
  struct Requester: AsyncSequence, AsyncIteratorProtocol {
    
    typealias AsyncIterator = Self
    typealias Element = (Permission, Status)
    
    private var permissions: [Permission]
    init(permissions: [Permission]) {
      self.permissions = permissions
    }
    
    func makeAsyncIterator() -> AsyncIterator { self }
    mutating func next() async -> Element? {
      guard !Task.isCancelled,
            let next = permissions.first
      else { return nil }
      
      let status = await requestPermission(for: next)
      self.permissions = Array(permissions.dropFirst())
      return (next, status)
    }
    
    private func requestPermission(for permission: Permission) async -> Status {
      await withCheckedContinuation { c in
        let type = permission
        let permission: PermissionsKit.Permission
        switch type {
        case .locationAlways: permission = LocationAlwaysPermission()
        case .locationWhenInUse: permission = LocationWhenInUsePermission()
        case .notifications: permission = NotificationPermission()
        case .motion: permission = MotionPermission()
        case .photos: permission = PhotoLibraryPermission()
        }
        permission.request {
          switch permission.status {
          case .authorized: c.resume(returning: .authorized)
          case .notDetermined,
              .notSupported: c.resume(returning: .notDetermined)
          case .denied: c.resume(returning: .denied)
          }
        }
      }
    }
    
  }
}

// MARK: - Read Permissions

extension PermissionService {
  
  struct Fetcher: AsyncSequence, AsyncIteratorProtocol {
    
    typealias AsyncIterator = Self
    typealias Element = (Permission, Status)
    
    private var permissions: [Permission]
    init(permissions: [Permission]) {
      self.permissions = permissions
    }
    
    func makeAsyncIterator() -> AsyncIterator { self }
    mutating func next() async -> Element? {
      guard !Task.isCancelled,
            let next = permissions.first
      else { return nil }
      
      let success = await fetchPermission(for: next)
      self.permissions = Array(permissions.dropFirst())
      return (next, success)
    }
    
    private func fetchPermission(for permission: Permission) async -> Status {
      let type = permission
      let permission: PermissionsKit.Permission
      switch type {
      case .locationAlways: permission = LocationAlwaysPermission()
      case .locationWhenInUse: permission = LocationWhenInUsePermission()
      case .notifications: permission = NotificationPermission()
      case .motion: permission = MotionPermission()
      case .photos: permission = PhotoLibraryPermission()
      }
      switch permission.status {
      case .authorized: return .authorized
      case .notDetermined,
          .notSupported: return .notDetermined
      case .denied: return .denied
      }
    }
    
  }
}
