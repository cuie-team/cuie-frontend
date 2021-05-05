//
//  Socket.swift
//  Messenger
//
//  Created by alongkot on 5/5/2564 BE.
//

import Foundation
import SocketIO
import SwiftyJSON

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    private let manager = SocketManager(socketURL: URL(string: Shared.url)!,
                                config: [.log(true), .compress])
    
    private var socket: SocketIOClient!
    
    override private init() {
        super.init()
        
        socket = manager.defaultSocket
    }
    
    func testToServer() {
        socket.emit("test:to_server", "hello ponek")
        socket.on("test:from_server") { (dataArray, ack) in
            print(dataArray)
        }
    }

    func connectToServerWithId(id: [String: Any]) {
        socket.emit("session_id", id)
    }
    
    func sendMessage(message: String, with id: String) {
        socket.emit("chatMessage", id, message)
    }
    
    func getMessage(completionHandler: @escaping (_ messagesInfo: [String: AnyObject]) -> Void) {
        socket.on("newMessage") { (dataArray, ack) in
            let messageDictionary = [String: AnyObject]()
            
            completionHandler(messageDictionary)
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
}
