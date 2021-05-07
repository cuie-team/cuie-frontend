//
//  Message.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import Foundation
import MessageKit

struct Message: MessageType, Equatable {
    
    var sender: SenderType
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKind
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    init(sender: SenderType, messageId: String, text: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = Date()
        self.kind = .text(text)
    }
    
    init(with chat: ChatInfo, sender: SenderType) {
        self.sender = sender
        self.messageId = chat.messageID
        self.sentDate = Date().textISOToDate(text: chat.sendtime)
        self.kind = .text(chat.message)
    }
}

extension MessageKind {
    var textValue: String {
        switch self {
        case .text(let text):
            return text
        default: return ""
        }
    }
}
