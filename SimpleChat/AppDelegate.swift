//
//  AppDelegate.swift
//  SimpleChat
//
//  Created by mhaddl on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static let CloudKitNotificationName = NSNotification.Name("CloudKitNotificationName")
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let loginViewController = LoginViewController()
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
 
        application.registerForRemoteNotifications()
        let center  = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
        }
        application.registerForRemoteNotifications()
        return true
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let notification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        NotificationCenter.default.post(name: AppDelegate.CloudKitNotificationName, object: notification)
        completionHandler(UIBackgroundFetchResult.newData)
    }

}

