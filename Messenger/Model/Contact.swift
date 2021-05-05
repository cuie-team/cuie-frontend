//
//  Contact.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import Foundation

struct UserContact: Codable {
    var all: [ContactInfo] = []
    var professors: [ContactInfo] = []
    var students: [ContactInfo] = []
    var staffs: [ContactInfo] = []
}

struct ContactInfo: Codable {
    let userID: String
    let name: String
    let surname: String
    let status: String
    
    func search(by text: String) -> Bool {
        if text == "" { return true }
        return self.userID.contains(text) || self.name.lowercased().contains(text) || self.surname.lowercased().contains(text) || self.status.lowercased().contains(text)
    }
}
