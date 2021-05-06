//
//  Profile.swift
//  Messenger
//
//  Created by alongkot on 6/5/2564 BE.
//

import Foundation

struct Profile: Codable {
    var userID: String = ""
    var name: String  = ""
    var surname: String = ""
    var status: String  = ""
    var email: String  = ""
    var bio: String?
    var picPath: String?
}
