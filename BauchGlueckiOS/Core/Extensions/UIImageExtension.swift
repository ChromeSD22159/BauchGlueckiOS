//
//  UIImageExtension.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 25.11.24.
//

import UIKit

extension UIImage {
    func resizedAndCropped(to size: CGSize) -> UIImage? {
        // Berechne den Skalierungsfaktor, um das Bild proportional zu skalieren
        let scale = max(size.width / self.size.width, size.height / self.size.height)
        
        // Skaliere die Breite und Höhe des Bildes
        let scaledWidth = self.size.width * scale
        let scaledHeight = self.size.height * scale
        
        // Berechne die Position, um das Bild mittig zuzuschneiden
        let x = (size.width - scaledWidth) / 2.0
        let y = (size.height - scaledHeight) / 2.0
        
        // Erstelle ein Rechteck mit der korrekten Position und Größe
        let drawRect = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        
        // Erstelle den Kontext und zeichne das Bild
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: drawRect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    } 
}
