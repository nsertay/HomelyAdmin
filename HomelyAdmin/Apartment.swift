//
//  Apartment.swift
//  HomelyAdmin
//
//  Created by Nurmukhanbet Sertay on 10.04.2023.
//

import Foundation

struct Apartment: Hashable{
     
    var name: String = ""
    var price: String = ""
    var address: String = ""
    var city: String = ""
    var commisDate: String = ""
    var image: String = ""
    
    
    func toDictionary() -> [String: Any] {
            return [
                "name": self.name,
                "price": self.price,
                "address": self.address,
                "city": self.city,
                "commisDate": self.commisDate,
                "image": self.image
            ]
    }
}
