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

struct RoomInfo: Codable {
    var roomID: String = ""
    var name: String?
    var lastMsg: String?
    var lastMsgTime: String?
    var members: [ContactInfo] = []
    var chats: [ChatInfo]?
}

struct ChatInfo: Codable {
    let messageID: String
    let senderID: String
    let name: String
    let surname: String
    let status: String
    let message: String
    let message_type: String
    let sendtime: String
    
    func isCurrentUser() -> Bool {
        return true
    }
}
