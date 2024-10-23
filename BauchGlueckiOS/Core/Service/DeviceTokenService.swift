//
//  DeviceTokenService.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 23.10.24.
//

import SwiftUI

class DeviceTokenService {
    static var shared = DeviceTokenService()
    func getSavedDeviceToken() -> String? {
        @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
        return deviceToken
    }

    func setDeviceToken(token: String) {
        @AppStorage("DEVICE_TOKEN", store: UserDefaults(suiteName: "group.bauchglueck")) var deviceToken = ""
        deviceToken = token
    }
}
