//
//  ChatViewController.swift
//  Chat NoGPT
//
//  Created by estech on 6/2/23.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate  {

    var contacto : Contacto!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textoMensaje: UITextField!
    
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
        remitente = defaults.string(forKey: "miNick")
        tokenRemitente = defaults.string(forKey: "miToken")
        print(tokenRemitente! ,remitente!)

        //Ocultar Teclado
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        // Definir delegados de los TextFields
        for textField in view.textFieldsInView {
            textField.delegate = self
        }
    }
    
    @IBAction func EnviarMensaje(_ sender: Any) {
        let mensaje = textoMensaje.text
        tokenDestino = contacto.token
        let urlFinal = URL(string: "\(url)TokenPush=\(tokenDestino!)&message=\(mensaje!)&remitente=\(remitente!)&tokenRemitente=\(tokenRemitente!)")
        var request = URLRequest(url: urlFinal!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlFinal!)
        print(urlFinal!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacto.mensajes.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModeloCeldaChat", for: indexPath) as! chatTableViewCell
        
        cell.mensajeLabel.text = contacto.mensajes[indexPath.row].texto
        
        return cell
    }
    
    // TEclado
    
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
    
    //@objc -> Escribir en objetiveC
    @objc func mostrarTeclado(notification : NSNotification){
        print("Se va a mostrar el teclado")
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
        print("Se va a ocultar el teclado")
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

