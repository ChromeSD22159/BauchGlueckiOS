//
//  GoogleAppOpenAd.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

final class GoogleAppOpenAd: NSObject, GADFullScreenContentDelegate, Observable {
   var appOpenAd: GADAppOpenAd?
   var loadTime = Date().timeIntervalSince1970
   
    func requestAppOpenAd(adId: String) {
       ATTrackingManager.requestTrackingAuthorization { status in
           
           guard GoogleAppStartrequest.requestHandler else {
               print("[OPEN AD] HANDLER REQUEST FAILED")
               return
           }
           
           guard self.appOpenAd == nil else {
               print("[OPEN AD] Already loaded")
               return
           }
           
           print("[OPEN AD] REQUESTED")
     
           let request = GADRequest()
           
           GADAppOpenAd.load(withAdUnitID: adId,
                             request: request,
                             completionHandler: { (appOpenAdIn, _) in
                               self.appOpenAd = appOpenAdIn
                               self.appOpenAd?.fullScreenContentDelegate = self
                               self.loadTime = Date().timeIntervalSince1970
                               print("[OPEN AD] Ad is loaded \(getLastShownOpenApp())")

                               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                 self.tryToPresentAd()
                               }
             })
       }
   }
   
   func tryToPresentAd() {
       
       guard GoogleAppStartrequest.requestHandler else {
           return print("Some Error")
       }
       
       if let gOpenAd = self.appOpenAd {
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
           if let rootViewController = windowScene?.windows.last?.rootViewController {
               gOpenAd.present(fromRootViewController: rootViewController)
               setLastShownOpenApp(timeStamp: Date().timeIntervalSince1970)
           } else {
               print("[OPEN AD] No root view controller found")
           }
       }
   }

   func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("[OPEN AD] Failed: \(error)")
   }
   
   func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("[OPEN AD] Ad dismissed")
   }
}

func getLastShownOpenApp() -> Double {
    return UserDefaults(suiteName: "group.bauchglueck")?.double(forKey: "OpenAdLastShow") ?? 0.0
}

func setLastShownOpenApp(timeStamp: Double) {
    UserDefaults(suiteName: "group.bauchglueck")?.set(timeStamp, forKey: "OpenAdLastShow")
}

enum GoogleAppStartrequest {
    static var requestHandler: Bool {
        let openAdLastShow = getLastShownOpenApp()
        guard openAdLastShow < targetDate.timeStamp else {
            print("[OPEN AD] Last seen less than \(targetDate.error) ago")
            return false
        }
        return true
    }
    
    static var targetDate: (timeStamp: Double, error: String) {
        let timeStamp = Date().addingTimeInterval(-6 * 60 * 60).timeIntervalSince1970
        return (timeStamp, "6 hours")
    }
    
    static var adId = "ca-app-pub-5150691613384490/5937311907"
}

func requestTrackingPermission() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                // Tracking erlaubt, hier kannst du die IDFA abrufen
                let idfa = ASIdentifierManager.shared().advertisingIdentifier
                print("Tracking erlaubt: \(idfa)")
            case .denied, .restricted, .notDetermined:
                // Tracking abgelehnt oder nicht verfügbar
                print("Tracking nicht erlaubt")
            @unknown default:
                print("Unbekannter Status")
            }
        }
    }
}
