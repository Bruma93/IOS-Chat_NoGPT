//
//  ViewController.swift
//  Chat NoGPT
//
//  Created by estech on 1/2/23.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let defaults = UserDefaults.standard
    
    
    var juan = Contacto(clave : "Jesús",token: "991c301356023c2c06fdd7a91844561448417498ca974304c0980a924c34165e", mensajes: [
        Mensaje(usuario: "Jesús",
                texto:"Te vienes?"),
        Mensaje(usuario:"yo", texto:"No puedo tio")
    ])
    
    var contactos : [Contacto] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        var miNick = defaults.string(forKey: "miNick")
        
        comprobarNick(nick : miNick)
        
        // Do any additional setup after loading the view.
        contactos.append(juan)
        
        var mensaje = defaults.string(forKey: "mensaje")
        print(mensaje)

        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Número de filas por sección
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModeloCeldaContacto", for: indexPath) as! ContactoTableViewCell
        
        cell.nombreContacto.text = contactos[indexPath.row].clave
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "startChat", sender: self)
    }
    
    // Asegurarnos antes de hacer el segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatViewController {
            destination.contacto = contactos[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    func comprobarNick(nick: String?){
        if let name = UserDefaults.standard.string(forKey: "miNick") {
            print(nick)
        } else {
            showAlert()
        }
    }
    
    func showAlert(){
        let ac = UIAlertController(title: "Nombre de perfil", message: nil, preferredStyle: .alert)
        
        ac.addTextField { (textField) in
                textField.placeholder = "Nombre de perfil"
            }
        
        //Clousure en la acción de enviar para poder obtener el valor del textField y poder crear la anotación
        ac.addAction(UIAlertAction(title: "Enviar", style: .default){ [self, weak ac] (_) in
            let textField = ac?.textFields![0]
            defaults.set(textField!.text, forKey: "miNick")
                        
        })
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        ac.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        
        present(ac, animated: true)
    }
    
    func anadirContacto(nombre : String){
        
    }


}

