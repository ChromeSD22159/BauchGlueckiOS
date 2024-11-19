//
//  GoogleAppOpenAd.swift
//  BauchGlueckiOS
//
//  Created by Frederik Kohler on 19.10.24.
//

/*
import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

final class GoogleAppOpenAd: NSObject, GADFullScreenContentDelegate, Observable {
    var appOpenAd: GADAppOpenAd?
    var loadTime = Date().timeIntervalSince1970
    var every: Double = 0
    
    func requestAppOpenAd(adId: String) {
        ATTrackingManager.requestTrackingAuthorization { status in
            do {
                guard try AdHelper.requestHandler(every: self.every) else {
                    print("[OPEN AD] HANDLER REQUEST FAILED")
                    return
                }

                guard self.appOpenAd == nil else {
                    throw AdError.alreayLoaded
                }

                print("[OPEN AD] REQUESTED")

                let request = GADRequest()
                GADAppOpenAd.load(withAdUnitID: adId, request: request) { appOpenAdIn, error in
                    if let error = error {
                        print("[OPEN AD] Failed to load ad: \(error)")
                        return
                    }

                    self.appOpenAd = appOpenAdIn
                    self.appOpenAd?.fullScreenContentDelegate = self
                    self.loadTime = Date().timeIntervalSince1970

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.tryToPresentAd()
                    }
                }
            } catch AdError.lastShownOpenAppTooRecent(let errorString) {
                print("[OPEN AD] \(errorString)")
            } catch AdError.alreayLoaded {
                print("[OPEN AD] Ad already loaded")
            } catch {
                print("[OPEN AD] Unexpected error: \(error)")
            }
        }
    }
   
    func tryToPresentAd() {
        do {
            guard try AdHelper.requestHandler(every: self.every) else {
                print("[OPEN AD] HANDLER REQUEST FAILED")
                return
            }
            
            if let gOpenAd = self.appOpenAd {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                if let rootViewController = windowScene?.windows.last?.rootViewController {
                    gOpenAd.present(fromRootViewController: rootViewController)
                    AdHelper.setLastShownOpenApp(timeStamp: Date().timeIntervalSince1970)
                } else {
                    print("[OPEN AD] No root view controller found")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("[OPEN AD] Failed: \(error)")
   }
   
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("[OPEN AD] Ad dismissed")
   }
}
 
struct AdHelper {
    static func getLastShownOpenApp() -> Double {
        return UserDefaults(suiteName: "group.bauchglueck")?.double(forKey: "OpenAdLastShow") ?? 0.0
    }

    static func setLastShownOpenApp(timeStamp: Double) {
        UserDefaults(suiteName: "group.bauchglueck")?.set(timeStamp, forKey: "OpenAdLastShow")
    }
    
    static func requestHandler(every: Double) throws -> Bool {
        let openAdLastShow = AdHelper.getLastShownOpenApp()
        /*
        let target = AdHelper.targetDate(hours: every)
        
        guard openAdLastShow < target.timeStamp else {
            throw AdError.lastShownOpenAppTooRecent(target.error)
        }
         */
        
        return true
    }
    
    static func targetDate(hours: Double = 6) -> (timeStamp: Double, error: String) {
        let timeStamp = Date().addingTimeInterval(-hours * 60 * 60).timeIntervalSince1970
        return (timeStamp, "\(hours) hours")
    }
    
    static var adId = "ca-app-pub-5150691613384490/5937311907"
}

enum AdError: Error {
    case noAdAvailable
    case alreayLoaded
    case lastShownOpenAppTooRecent(String)
}
*/



//
/*
 // import GoogleMobileAds
 //GADMobileAds.sharedInstance().start(completionHandler: nil)
 //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "527fdd25b08283eff613d67c9d301665" ]
 */

/// PROJECTTARGET PLIST:
///
/// NSUserTrackingUsageDescription: Diese App verwendet Ihre Daten, um personalisierte Werbung bereitzustellen und die Benutzererfahrung zu verbessern.

/*
 <key>GADApplicationIdentifier</key>
 <string>ca-app-pub-5150691613384490~7246324451</string>
 <key>SKAdNetworkItems</key>
 <array>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>cstr6suwn9.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>4fzdc2evr5.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>2fnua5tdw4.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>ydx93a7ass.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>p78axxw29g.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>v72qych5uu.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>ludvb6z3bs.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>cp8zw746q7.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>3sh42y64q3.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>c6k4g5qg8m.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>s39g8k73mm.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>3qy4746246.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>hs6bdukanm.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>mlmmfzh3r3.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>v4nxqhlyqp.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>wzmmz9fp6w.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>su67r6k2v3.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>yclnxrl5pm.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>7ug5zh24hu.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>gta9lk7p23.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>vutu7akeur.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>y5ghdn5j9k.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>v9wttpbfk9.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>n38lu8286q.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>47vhws6wlr.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>kbd757ywx3.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>9t245vhmpl.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>a2p9lx4jpn.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>22mmun2rn5.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>4468km3ulz.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>2u9pt9hc89.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>8s468mfl3y.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>ppxm28t8ap.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>uw77j35x4d.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>pwa73g5rt2.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>578prtvx9j.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>4dzt52r2t5.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>Tl55sbb4fm.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>e5fvkxwrpn.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>8c4e2ghe7u.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>3rd42ekr43.skadnetwork</string>
     </dict>
     <dict>
         <key>SKAdNetworkIdentifier</key>
         <string>3qcr597p9d.skadnetwork</string>
     </dict>
 </array>
 */
