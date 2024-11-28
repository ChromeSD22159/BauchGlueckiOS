//
//  SwiftDataDebug.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 28.11.24.
//
import Foundation
import SwiftUI

extension View {
    func homeDirectory() -> some View {
        modifier(HomeDirectory())
    }
}

struct HomeDirectory: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                let dbPath = SwiftDataDebugHelper.getDatabasePath()
                print(dbPath)
            }
    }
}


struct SwiftDataDebugHelper {
    static func getDatabasePath() -> String {
        return "\(NSHomeDirectory())/Documents/"
    }
    
    static func exportDatabase(dbName: String = "default.sqlite") {
        // Prüfen, ob die Datei existiert
        guard FileManager.default.fileExists(atPath: getDatabasePath() + dbName) else {
            print("Datenbank nicht gefunden.")
            return
        }
        
        // URL zur Datenbank
        let dbURL = URL(fileURLWithPath: getDatabasePath() + dbName)
        
        // UIActivityViewController zum Teilen der Datei
        let activityViewController = UIActivityViewController(activityItems: [dbURL], applicationActivities: nil)
        
        // Präsentieren des Controllers
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityViewController, animated: true, completion: nil)
        }
    }
}
