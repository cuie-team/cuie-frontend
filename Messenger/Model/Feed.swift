//
//  Feed.swift
//  Messenger
//
//  Created by alongkot on 28/3/2564 BE.
//

import Foundation
import UIKit

struct Feed: Codable {
    let postID: String
    let head: String
    let body: String
    let senderID: String
    let posttime: String?
    let filepath: String?
    let senderName: String
    let senderSurname: String
    let senderStatus: String
    let senderMajor: String?
    let senderPicpath: String?
}
