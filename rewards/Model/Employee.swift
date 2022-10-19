//
//  Employee.swift
//  rewards
//
//  Created by Kushal Vaghani on 11/10/22.
//

import Foundation
//employee model
class Employee: NSObject {
    
    var email: String
    var name: String
    var point: Int = 0
   
    init(email: String, name: String) {
        self.email = email
        self.name = name
    }
}
