//
//  ImageCache.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 04.11.24.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    
    private init() {}
}
