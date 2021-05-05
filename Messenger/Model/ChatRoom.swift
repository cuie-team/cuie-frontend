//
//  ChatRoom.swift
//  Messenger
//
//  Created by alongkot on 4/5/2564 BE.
//

import Foundation

struct ChatRoom: Codable {
    let roomID: String
    let name: String
    let roomType: String
    let lastMsg: String?
    let lastMsgTime: String?
    let lastMsgContext: String?
    let lastMsgType: String?
    let members: [String]
}
