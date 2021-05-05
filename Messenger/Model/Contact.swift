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
}
