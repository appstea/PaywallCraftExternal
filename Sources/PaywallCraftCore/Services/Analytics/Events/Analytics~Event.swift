//
//  Analytics~Event.swift
//
//  Created by dDomovoj on 10/27/20.
//  Copyright © 2022 AppsTea. All rights reserved.
//

import Foundation

import AnalyticsCraft

// MARK: - Public

extension Analytics.Service {

  func sendEvent(_ event: Analytics.Event) {
    send(event)
  }

}

extension Analytics {

  typealias PermissionsDomain = Permissions
  enum Event: IAnalyticsEvent {
    
    struct Permissions {
      typealias Status = PermissionsDomain.ViewModel.Permission.Status
      
      var notifications: Status?
      var location: Status?
      var motion: Status?
      var photos: Status?
    }
    case sessionDetails(Permissions)

//    enum Orientation: IAnalyticsValue {
//      case portrait
//      case landscape
//
//      var value: String {
//        switch self {
//        case .portrait: return "Portrait"
//        case .landscape: return "Landscape"
//        }
//      }
//    }
//    case orientationUsed(Orientation)

    var name: String {
      switch self {
      case .sessionDetails: return "Session Details"
//      case .orientationUsed: return "Orientation Used"
      }
    }

    var params: [String: Any]? {
      switch self {
      case .sessionDetails(let permissions):
        var result = [String: Any]()
        let transformer: (Permissions.Status) -> String = {
          switch $0 {
          case .authorized: return "Yes"
          case .denied: return "No"
          case .notDetermined: return "Not determined"
          }
        }
        if let notifications = permissions.notifications {
          result["Permission Notifications"] = transformer(notifications)
        }
        if let location = permissions.location {
          result["Permission Location"] = transformer(location)
        }
        if let motion = permissions.motion {
          result["Permission Motion"] = transformer(motion)
        }
        if let photos = permissions.photos {
          result["Permission Photo"] = transformer(photos)
        }

        return result
//        let value: String
//        switch notification {
//        case .allowed: value = "Yes"
//        case .denied: value = "No"
//        case .silent: value = "Quiet"
//        case .custom: value = "Custom"
//        }
//        return [
//          "Permission Notifications": value,
//        ]
//      case .orientationUsed(let orientation):
//        return ["Orientation": orientation.value]
      }
    }

  }
}
