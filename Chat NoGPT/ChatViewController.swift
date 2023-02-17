//
//  ChatViewController.swift
//  Chat NoGPT
//
//  Created by estech on 6/2/23.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {

    public var viewController : ViewController?
    
    var contacto : Contacto!
    var index : Int!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textoMensaje: UITextField!
    @IBOutlet weak var enviarButton: UIButton!
    
    let defaults = UserDefaults.standard
    let url = "https://test2.qastusoft.com.es/JesusMartinez/Chat/push.php?"
    var tokenDestino : String? = nil
    var remitente : String? = nil
    var tokenRemitente : String? = nil
    
    //var urlFinal = "\(url)TokenPush=\(tokenDestino)&message=\(mensaje)&remitente=\(remitente)&tokenRemitente=tokenRemitente"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //conexion con la vista
        let appDelegateChat = UIApplication.shared.delegate as! AppDelegate
        appDelegateChat.chatViewController = self
                
        remitente = defaults.string(forKey: "miNick")
        tokenRemitente = defaults.string(forKey: "miToken")
        
        //Ocultar Teclado
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        // Definir delegados de los TextFields
        for textField in view.textFieldsInView {
            textField.delegate = self
            
        }
        
        //Aspecto boton
        enviarButton.layer.cornerRadius = 10
        enviarButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = defaults.data(forKey: "contactos"),
           var contactos = try? JSONDecoder().decode([Contacto].self, from: data) {
            contacto = contactos[index]
            navigationItem.title = contacto.nombreUsuario
        }
        tableView.reloadData()
    }

    
    @IBAction func EnviarMensaje(_ sender: Any) {
        let mensaje = textoMensaje.text
        let horaActual = Date()
        let formateadorHora = DateFormatter()
        formateadorHora.dateFormat = "HH:mm"
        let horaString = formateadorHora.string(from: horaActual)
        
        let encodedMessage = mensaje!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // Decodificamos
        if let data = defaults.data(forKey: "contactos"),
           var contactos = try? JSONDecoder().decode([Contacto].self, from: data) {
            var i = 0
            for contact in contactos{
                print("El usuario se llama: \(contact.nombreUsuario)")
                print("El remitente se llama: \(contacto.nombreUsuario)")
                print("tiene valor: \(i)")
                if contacto.nombreUsuario == contact.nombreUsuario{
                    print("El elegido")
                    print("tiene valores: \(i)")
                    print(contactos[i])
                    contactos[i].mensajes.append(Mensaje(usuario: "yo", texto: mensaje!, hora: horaString))
                    //llamamos a la función codificar
                    codificar(contactos: contactos)
                    print("El contacto tiene esta info \(defaults.array(forKey: "contactos"))")
                }
                i += 1
            }
        }
        
        contacto.mensajes.append(Mensaje(usuario: "yo", texto: mensaje!,hora: horaString))
        
        tokenDestino = contacto.token
        //Borrar urlFinal
        print(url)
        print(tokenDestino!)
        print(mensaje!)
        print(remitente!)
        print(tokenRemitente!)
        print(contacto)
        
        
        guard let serviceUrl = URL(string: "\(url)TokenPush=\(tokenDestino!)&message=\(encodedMessage!)&remitente=\(remitente!)&TokenRemitente=\(tokenRemitente!)&hora=\(horaString)") else { return }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("Application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in

        }.resume()
        
        self.tableView.reloadData()
        textoMensaje.text = ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacto.mensajes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if contacto.mensajes[indexPath.row].usuario == contacto.nombreUsuario {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModeloCeldaChat1", for: indexPath) as! chatTableViewCell
            cell.mensajeLabel.text = contacto.mensajes[indexPath.row].texto
            cell.horaLabel.text = contacto.mensajes[indexPath.row].hora

            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ModeloCeldaChat2", for: indexPath) as! chatTableViewCell
            cell.mensajeLabel.text = contacto.mensajes[indexPath.row].texto
            cell.horaLabel.text = contacto.mensajes[indexPath.row].hora
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(contacto.mensajes[indexPath.row])
        let eliminarMensaje = indexPath.row
        showAlert(index: eliminarMensaje)
    }
    
    func showAlert(index : Int){
        print(index)
        let ac = UIAlertController(title: "Eliminar mensaje", message: nil, preferredStyle: .alert)
        
        //Clousure en la acción de enviar para poder obtener el valor del textField y poder crear la anotación
        ac.addAction(UIAlertAction(title: "Eliminar", style: .default){ [self, weak ac] (_) in
            
            contacto.mensajes.remove(at: index)
            
            if let data = UserDefaults.standard.data(forKey: "contactos"),
               var contactos = try? JSONDecoder().decode([Contacto].self, from: data) {
                for contact in contactos {
                    var i = 0
                    if contacto.nombreUsuario == contact.nombreUsuario{
                        print(contacto.nombreUsuario)
                        print(contact.nombreUsuario)
                        print(contactos[i].mensajes.count)
                        contactos[i].mensajes.remove(at: index)
                        //llamamos a la función codificar
                        codificar(contactos: contactos)
                    }
                    i += 1
                }
            }
            
            tableView.reloadData()
        })
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    //Función para transformar a JSON el array de contacto y guardarlo
    func codificar(contactos : [Contacto]){
        do {
            let data = try JSONEncoder().encode(contactos)
            UserDefaults.standard.set(data, forKey: "contactos")
        } catch {
            print("Error al codificar el array de contactos: \(error)")
        }
    }
    
    
    // Configuar el Teclado
    override func viewDidAppear(_ animated: Bool) {
        //Registrar observadores para destectar cuando se muestra u oculta el teclado
        NotificationCenter.default.addObserver(self, selector: #selector(mostrarTeclado), name: UIResponder.keyboardWillShowNotification, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(ocultarTeclado), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Eliminar observadores
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Pasar al siguiente textField
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag){
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc func mostrarTeclado(notification : NSNotification){
        //print("Se va a mostrar el teclado")
        if let keyboadSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            if let seleccionado = view.selectedTextField{
                // esquina superior izquierda
                if seleccionado.frame.origin.y + seleccionado.frame.height > UIScreen.main.bounds.size.height - keyboadSize.height {
                    // El teclado tapa el textField seleccionado
                    if self.view.frame.origin.y == 0{
                        self.view.frame.origin.y -= keyboadSize.height
                    }
                }
            }
        }
    }
    
    @objc func ocultarTeclado(nofitication : NSNotification){
        //print("Se va a ocultar el teclado")
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    
    }
    
}

extension UIView{
    var textFieldsInView : [UITextField] {
        return subviews
            .filter({ !($0 is UITextField) })
            .reduce((subviews.compactMap{$0 as? UITextField}), {summ, current in
                return summ + current.textFieldsInView
            })
    }
    
    var selectedTextField: UITextField? {
        return textFieldsInView.filter{ $0.isFirstResponder }.first
    }
}

