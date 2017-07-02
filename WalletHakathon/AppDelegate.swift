//
//  AppDelegate.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var initialViewController: UIViewController
        
        if(UserDefaults.standard.string(forKey: "token") != nil){
            initialViewController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
            //initialViewController =  walkthrought.instantiateViewController(withIdentifier: "start")
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let firstPage = OnboardingContentViewController(title: "Wallet Messenger", body: "Добро пожаловать! ", image: #imageLiteral(resourceName: "1st"), buttonText: "") { () -> Void in
            }
            
            firstPage.underTitlePadding = 30
            
            
            let secondPage = OnboardingContentViewController(title: "", body:  "Записывайте, совершайте и подтверждайте совместные платежи", image: #imageLiteral(resourceName: "2ndpage"), buttonText: "") { () -> Void in

            }
            
            let thirdPage = OnboardingContentViewController(title: "", body: "Привяжите свой QIWI кошелёк для расчета прямо в приложении", image: #imageLiteral(resourceName: "3rdpage"), buttonText: "") { () -> Void in

            }
            
            let fourthPage = OnboardingContentViewController(title: "", body: "", image: #imageLiteral(resourceName: "4th"), buttonText: "Начать использование!") { () -> Void in
                let viewController = storyboard.instantiateViewController(withIdentifier: "loginController")
                self.window?.rootViewController = viewController
                self.window?.makeKeyAndVisible()
            }
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "Только финансы, ничего личного лишнего")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(23, 8))
            
            
            fourthPage.bodyLabel.attributedText = attributeString
            
            
            firstPage.topPadding = 50
            thirdPage.titleLabel.text = ""
            
            thirdPage.topPadding = 100
            fourthPage.topPadding = 85
            secondPage.topPadding = 100
            
            initialViewController = OnboardingViewController(backgroundImage: UIImage(named: "back"), contents: [firstPage, secondPage, thirdPage,fourthPage])
            
            if let vc = initialViewController as? OnboardingViewController{
                vc.shouldMaskBackground = false 
            }

        }
        
        UINavigationBar.appearance().barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "back"))
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.white
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

}

