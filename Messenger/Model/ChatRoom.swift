//
//  ChatRoom.swift
//  Messenger
//
//  Created by alongkot on 4/5/2564 BE.
//

import Foundation

struct ChatRoom: Codable {
    let roomID: String
    let name: String?
    let picpath: String?
    let roomType: String
    let lastMsg: String?
    let lastMsgTime: String?
    let lastMsgContext: String?
    let lastMsgType: String?
    let members: [ContactInfo]
    let owner: ContactInfo
    
    func getRoomImg() -> String? {
        return self.picpath
    }
}

struct RoomInfo: Codable {
    var roomID: String = ""
    var name: String?
    var members: [ContactInfo] = []
    var owner: ContactInfo?
    var chats: [ChatInfo]?
    
    func getName(by id: String) -> String? {
        for info in members {
            if info.userID == id {
                return info.name
            }
        }
        return nil
    }
    
    func getAvatar(by id: String) -> String? {
        for info in members {
            if info.userID == id {
                return info.picpath
            }
        }
        return nil
    }
}

struct ChatInfo: Codable {
    let messageID: String
    let senderID: String
    let message: String
    let messageType: String
    let sendtime: String
    
    func search(by members: [Sender]) -> Sender? {
        for sender in members {
            if sender.senderId == senderID {
                return sender
            }
        }
        return nil
    }
}
