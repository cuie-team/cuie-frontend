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
}
