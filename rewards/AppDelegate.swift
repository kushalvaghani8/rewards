//
//  AppDelegate.swift
//  rewards
//
//  Created by Kushal Vaghani on 25/09/2022.
//

import UIKit
import FirebaseCore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let shared = UIApplication.shared.delegate as! AppDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Firebase configuration
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    //Manage Login User
    func manageLogin() {
        
        //Get Current User Login from Firebase SDK
        if let user = Auth.auth().currentUser {
            //Get Email from Current Login User
            guard let email = user.email else { return }
            
            //Check email content for manager or employee
            if email.contains("manager") {
                let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ManagerDashboardNVC")
                window?.rootViewController = VC
                window?.makeKeyAndVisible()
            } else {
                let NVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmployeeDashboardNVC")
                window?.rootViewController = NVC
                window?.makeKeyAndVisible()
            }
        } else {
            // IF No any User login else set Login page
            let nav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
            window?.rootViewController = nav
            window?.makeKeyAndVisible()
        }
    }

}

//MARK: - UIViewController
extension UIViewController {
    //Show Alert With OK Button
    func showAlertWithOKAction(title: String, message : String, completionBlock: ((Bool) -> ())? = nil){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "OK", style: .default) { (action) in
            if completionBlock != nil{
                completionBlock!(true)
            }
        }
        alert.addAction(actionYes)
        self.present(alert, animated: true)
    }
    
    
    //Show Alert With Yes and NO Button
    func showAlertWithYESNOAction(title: String, message : String, yescompletionBlock: ((Bool) -> ())? = nil, nocompletionBlock: ((Bool) -> ())? = nil){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let actionYes = UIAlertAction(title: "Yes", style: .default) { (action) in
            if yescompletionBlock != nil{
                yescompletionBlock!(true)
            }
        }
        let actionNo = UIAlertAction(title: "No", style: .default) { (action) in
            if nocompletionBlock != nil{
                nocompletionBlock!(true)
            }
        }
        alert.addAction(actionYes)
        alert.addAction(actionNo)
        self.present(alert, animated: true)
    }
}

