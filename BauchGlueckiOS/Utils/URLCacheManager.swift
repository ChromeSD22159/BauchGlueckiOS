//
//  invalidateURLCache.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation

class URLCacheManager {
    static let shared = URLCacheManager()
    
    private var previousUUID: String? // Um den vorherigen UUID-String zu speichern
    
    // Methode, um eine eindeutige URL zu generieren
    func generateUniqueUrl(for urlString: String) -> URL {
        let newUUID = UUID().uuidString
        let uniqueUrl = URL(string: "\(urlString)?v=\(newUUID)")!
        
        // Prüfe, ob der UUID-String sich geändert hat
        if previousUUID != newUUID {
            // Cache invalidieren, wenn sich der UUID-String geändert hat
            invalidateURLCache(for: uniqueUrl)
            // Den neuen UUID speichern
            previousUUID = newUUID
        }
        
        return uniqueUrl
    }

    // Methode, um den Cache für eine bestimmte URL zu invalidieren
    func invalidateURLCache(for url: URL) {
        let request = URLRequest(url: url)
        URLCache.shared.removeCachedResponse(for: request)
        print("Cache für URL entfernt: \(url.absoluteString)")
    }
}
