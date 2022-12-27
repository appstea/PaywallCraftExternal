//
//  Device.swift
//
//  Created by dDomovoj on 12/27/22.
//

import Foundation

#if targetEnvironment(macCatalyst)
let isCatalyst = true
#else
let isCatalyst = false
#endif

var isMacDesignedForPad: Bool {
  if #available(iOS 14.0, *) {
    return ProcessInfo.processInfo.isiOSAppOnMac
  } else {
    return false
  }
}
