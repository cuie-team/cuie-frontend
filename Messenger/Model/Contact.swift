//
//  Contact.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import Foundation

struct UserContact{
    var list: [ContactInfo] = []
}

struct ContactInfo {
    var name: String
    var surname: String
    var status: String
    var userID: String
    var email: String

}
