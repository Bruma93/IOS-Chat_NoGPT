//
//  AppDelegate.swift
//  Chat NoGPT
//
//  Created by estech on 1/2/23.
//

import UIKit
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().delegate = self
                
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
    
    func registerForPushNotifications()/*Nombre descriptivo que le hemos puesto a la función*/{
        //Pedir permiso al usuario para recibir notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){granted, error in
            print("permiso concedido: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
            
            
            //Define acciones personalizadas
            let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Aceptar", options: [.foreground])
            let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Rechazar", options: [.foreground])
            
            //Definir el tipo de notificación
            let meatingInviteCategory = UNNotificationCategory(identifier: "MEETING_INVITATION", actions: [acceptAction, declineAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
            
            //Registrar el tipo de Notificación
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.setNotificationCategories([meatingInviteCategory])
        }
    }
    
    func getNotificationSettings(){
        UNUserNotificationCenter.current().getNotificationSettings{ settings in
            //print("Configuración push: \(settings)")
            //Comprobamos que el usuario nos ha autorizado a enviarle notificaciones
            guard settings.authorizationStatus == .authorized else { return }
            
            //Registralo en APNs
            DispatchQueue.main.sync {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    //Si se ha completado el registro
    func application(_ application : UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken : Data){
        let tokenParts = deviceToken.map{ data in String(format:"%02.2hhx",data)}
        let token = tokenParts.joined()
        print("Device token:\(token)")
    }
    
    func application(_ application : UIApplication, didRegisterForRemoteNotificationsWitherror error : Error){
        
        print("Failed to register :\(error)")
    }


}

