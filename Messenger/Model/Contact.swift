//
//  Contact.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import Foundation

struct UserContact: Codable {
    var professor: [ContactInfo] = []
    var staff: [ContactInfo] = []
    var student: [ContactInfo] = []
}

struct ContactInfo: Codable {
    let name: String
    let surname: String
    let status: String
    let userID: String
}
