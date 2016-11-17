//
//  AppDelegate.swift
//  3DTouch
//
//  Created by 王正一 on 16/11/17.
//  Copyright © 2016年 FsThatOne. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var launchShortItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let shortcut = launchShortItem else { return }
        _ = handle(shortcut)
        launchShortItem = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

// MARK: - 3D Touch Settings
extension AppDelegate {
    
    enum ShortCutIdentifider: String {
        case Scan
        case Chat
        case Wifi
        
        init?(fullIdentifier: String) {
            guard let shortCutType = fullIdentifier.components(separatedBy: ".").last else {
                return nil
            }
            self.init(rawValue: shortCutType)
        }
        
        var type: String {
            return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
        }
        
    }
    
    func handle(_ shortCutItem: UIApplicationShortcutItem) -> Bool {
        var handled = false
        
        guard ShortCutIdentifider(fullIdentifier: shortCutItem.type) != nil else { return false }
        
        guard let shortCutType = shortCutItem.type as String? else { return false }
        
        switch (shortCutType) {
        case ShortCutIdentifider.Scan.type:
            // Handle shortcut 1
            handled = true
            break
        case ShortCutIdentifider.Chat.type:
            // Handle shortcut 2
            handled = true
            break
        case ShortCutIdentifider.Wifi.type:
            // Handle shortcut 3
            handled = true
            break
        default:
            break
        }
        return handled
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handle(shortcutItem))
    }
    
}

