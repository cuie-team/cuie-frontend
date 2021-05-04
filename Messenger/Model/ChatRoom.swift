//
//  ChatRoom.swift
//  Messenger
//
//  Created by alongkot on 4/5/2564 BE.
//

import Foundation
import UIKit

protocol ChatRoomDelegate: class {
    func receive(message: Message)
}

class ChatRoom: NSObject {
    weak var delegate: ChatRoomDelegate?
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var userName: String = ""
    var otherName: String = ""
    var maxReadLength: Int = 4096
    
    func setupNetworkCommunication() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           "localhost" as CFString,
                                           80,
                                           &readStream,
                                           &writeStream)
        
        //Prevent memory leak in the future
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        //Run loop
        inputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        //Open gates
        inputStream.open()
        outputStream.open()
    }
    
    func joinChat(userName: String, otherName: String) {
//        let data = "iam:\(userName)".data(using: .utf8)!
        
        self.userName = userName
        self.otherName = otherName
        
//        data.withUnsafeBytes {
//            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
//                print("Error joining chat")
//                return
//            }
//
//            outputStream.write(pointer, maxLength: data.count)
//        }
    }
    
    func send(message: String) {
        let data = "msg:\(message)".data(using: .utf8)!
        
        data.withUnsafeBytes {
            guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                print("Error joining chat")
                return
            }
            outputStream.write(pointer, maxLength: data.count)
        }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }

}

extension ChatRoom: StreamDelegate {
    //MARK:- To tell that message has come
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            stopChatSession()
        case .errorOccurred:
            print("error occurred")
        case .hasSpaceAvailable:
            print("has space available")
        default:
            print("some other event...")
        }
    }
    
    //MARK:- To handle the incoming message
    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0, let error = stream.streamError {
                print(error)
                break
            }
            
            // Construct the Message object
            if let message = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                //Notify user
                delegate?.receive(message: message)
            }
        }
    }
    
    //MARK:- To construct the message object
    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>,
                                        length: Int) -> Message? {
        guard
            let stringArray = String(
                bytesNoCopy: buffer,
                length: length,
                encoding: .utf8,
                freeWhenDone: true)?.components(separatedBy: ":"),
            let name = stringArray.first,
            let message = stringArray.last
        else {
            return nil
        }
        
        let currentUser: Sender = (name == self.userName) ? Sender(senderId: "self", displayName: self.userName): Sender(senderId: "other", displayName: self.otherName)
        
        return Message(sender: currentUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(message))
    }
}
