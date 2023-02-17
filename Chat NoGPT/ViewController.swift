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
    
    var contactosAlmacenados : [Contacto] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        //conexion con la vista
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController = self
        
        comprobarNick()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = UserDefaults.standard.data(forKey: "contactos"),
            let contactos = try? JSONDecoder().decode([Contacto].self, from: data) {
            print("SDFDSFSDFFSDFSDSDF\(contactos)")
            contactosAlmacenados = contactos
            tableView.reloadData()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Número de filas por sección
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactosAlmacenados.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ModeloCeldaContacto", for: indexPath) as! ContactoTableViewCell
        
        cell.nombreContacto.text = contactosAlmacenados[indexPath.row].nombreUsuario
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "startChat", sender: self)
    }
    
    // Asegurarnos antes de hacer el segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChatViewController {
            //destination.contacto = contactosAlmacenados[tableView.indexPathForSelectedRow!.row]
            destination.index = tableView.indexPathForSelectedRow!.row
        }
    }
    
    // Función para comprobar si al abir la aplicación, el usuario tiene un nick asignado
    func comprobarNick(){
        
        if let _ = UserDefaults.standard.string(forKey: "miNick") {
            
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

