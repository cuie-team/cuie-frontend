//
//  Socket.swift
//  Messenger
//
//  Created by alongkot on 5/5/2564 BE.
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    private let manager = SocketManager(socketURL: URL(string: Shared.url)!, config: [.log(false), .compress])
    
    private var socket: SocketIOClient!
    
    override private init() {
        super.init()
        
        socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, _ in
            print("socket connected")
        }
        
        socket.on("signin:response") { (data, _) in
            print(data)
        }
        
        socket.on("chat:send:response") { (data, _) in
            print(data)
        }
        
    }
    
    func signin(user: User) {
        socket.emit("signin", user.dictionary!)
    }
    
    func sendMessage(message: MessageObject) {
        socket.emit("chat:send", message.dictionary!)
    }
    
    func getMessage(completionHandler: @escaping (_ messagesInfo: [String: String]) -> Void) {
        socket.on("chat:receive") { (dataArray, _) in
            completionHandler(dataArray[0] as! [String : String])
        }
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
}
