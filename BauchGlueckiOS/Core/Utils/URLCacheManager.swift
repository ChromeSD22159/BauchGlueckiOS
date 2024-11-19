//
//  invalidateURLCache.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 22.10.24.
//

import Foundation

class URLCacheManager {
    static let shared = URLCacheManager()
    
    private var previousUUID: String?
    

    func generateUniqueUrl(for urlString: String) -> URL {
        let newUUID = UUID().uuidString
        let uniqueUrl = URL(string: "\(urlString)?v=\(newUUID)")!
  
        if previousUUID != newUUID {
            invalidateURLCache(for: uniqueUrl)
            previousUUID = newUUID
        }
        
        return uniqueUrl
    }


    func invalidateURLCache(for url: URL) {
        let request = URLRequest(url: url)
        URLCache.shared.removeCachedResponse(for: request)
    }
}
