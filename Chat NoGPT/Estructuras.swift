//
//  Estructuras.swift
//  Chat NoGPT
//
//  Created by estech on 6/2/23.
//

import Foundation


struct Contacto : Codable{
    let clave : String
    let token : String
    let mensajes : [Mensaje]
}

struct Mensaje : Codable{
    let usuario : String
    let texto : String
}

