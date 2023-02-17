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
    
    public var viewController : ViewController?
    public var chatViewController : ChatViewController?

    let defaults = UserDefaults.standard

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications()
        
        UNUserNotificationCenter.current().delegate = self
                
        let notificationOption = launchOptions?[.remoteNotification]
        
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
        defaults.set(token, forKey: "miToken")
        print(defaults.string(forKey: "miToken")!)
        print("Device token:\(token)")
    }
    
    func application(_ application : UIApplication, didRegisterForRemoteNotificationsWitherror error : Error){
        
        print("Failed to register :\(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String:AnyObject] else {
            completionHandler(.failed)
            return
        }
        print(aps)
        print("El sonido es \(aps["alert"]!)")
        
        
        guard let notif = userInfo as? [String:AnyObject] else {
            completionHandler(.failed)
            return
        }
        
        print("Este es el \(notif)")
        
        //Modificar el Budge
        if let pushBadgeNumber:Int = aps["badge"] as? Int{
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BadgeChanged"), object: nil)
            UIApplication.shared.applicationIconBadgeNumber = pushBadgeNumber
        }
        
        //defaults.set(notif["aps"]!["alert"], forKey: "mensaje")
        
        //Comprobar si existe UserDefaults.standard.array(forKey: "contactos")
        // Decodificamos de nuevo el array contactos almacenado en UserDefaults
        if let data = UserDefaults.standard.data(forKey: "contactos"),
           var contactos = try? JSONDecoder().decode([Contacto].self, from: data) {
            let nombreUsuario = notif["remitente"]
            // Comprobar si el contacto existe
            print("Existe contactos")
            
            var existe = false
            var i = 0

             for contacto in contactos {
                
                if nombreUsuario! as! String == contacto.nombreUsuario{
                    print(contactos[i].nombreUsuario)
                    // Como el usuario existe, le añadimos el mensaje a la información de su Contacto
                    contactos[i].mensajes.append(Mensaje(
                        usuario: notif["remitente"] as! String,
                        texto: notif["aps"]!["alert"] as! String,
                        hora: notif["hora"] as! String)
                    )
                    existe = true
                    
                    break
                }
                i += 1
            }
            
            // Si no existe el contacto creamos uno nuevo y se lo añadimos al UserDefaults
            if !existe{
                contactos.append(
                    Contacto(
                        nombreUsuario: notif["remitente"] as! String,
                        token: notif["tokenRemitente"] as! String,
                        mensajes: [
                            Mensaje(usuario: notif["remitente"] as! String,
                                    texto: notif["aps"]!["alert"] as! String,
                                    hora: notif["remitente"] as! String),
                        ]
                    )
                )
            }
            
            //Codificar a Json
            do {
                let data = try JSONEncoder().encode(contactos)
                UserDefaults.standard.set(data, forKey: "contactos")
            } catch {
                print("Error al codificar el array de contactos: \(error)")
            }
            
            // Recarga los datos en el tableView del ViewController con el nombre del nuevo usuario que nos ha escrito
            viewController?.tableView.reloadData()
            chatViewController?.tableView.reloadData()
            
        }else {
            print("Creamos el array de contactos")
            let contactos = [Contacto(nombreUsuario : notif["remitente"]! as! String ,
                                      token : notif["tokenRemitente"] as! String,
                                      mensajes : [Mensaje(usuario: notif["remitente"] as! String , texto : notif["aps"]!["alert"] as! String, hora: notif["hora"] as! String)
                                                 ]
                                     )]
            //Codificar a Json
            do {
                let data = try JSONEncoder().encode(contactos)
                UserDefaults.standard.set(data, forKey: "contactos")
            } catch {
                print("Error al codificar el array de contactos: \(error)")
            }
            print("ya hemos creado el array de contactos")
        }
    }
    
 



}

