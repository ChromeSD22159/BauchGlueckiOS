//
//  AppUser.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 14.11.24.
//

struct AppUser {
    var name: String = ""
    var email: String = ""
    var appToken: String = ""
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "appToken": appToken
        ]
    }
}
