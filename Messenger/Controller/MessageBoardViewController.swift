//
//  MessageBoardViewController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class MessageBoardViewController: MessagesViewController {
    
    let currentUser: Sender = Sender(senderId: "self", displayName: "Pon-ek")
    
    let otherUser: Sender = Sender(senderId: "other", displayName: "Thanainan")
    
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMessage()
        setCollectionView()
        setInputBar()
    }
    
    private func getMessage() {
        messages.append(Message(
                            sender: currentUser,
                            messageId: "1",
                            sentDate: Date().addingTimeInterval(-86400),
                            kind: .text("Hello!!")))
        
        messages.append(Message(
                            sender: otherUser,
                            messageId: "2",
                            sentDate: Date().addingTimeInterval(-66400),
                            kind: .text("How's it going")))
        
        messages.append(Message(
                            sender: currentUser,
                            messageId: "3",
                            sentDate: Date().addingTimeInterval(-16400),
                            kind: .text("Covid19 spreading")))
        
        messages.append(Message(
                            sender: currentUser,
                            messageId: "4",
                            sentDate: Date().addingTimeInterval(-6400),
                            kind: .text("Sad")))
    }
    
    private func setCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setInputBar() {
        messageInputBar.delegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 20, animated: true)
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        
        messagesCollectionView.reloadData()
        
        if isLatestMessage {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
}

extension MessageBoardViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    //MARK: - setup for MessagesDataSource
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    //MARK: - setup for MessageLayoutDelegate
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: 0, height: 8)
    }
    
    //MARK: - setup for MessagesDisplayDelegate
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(corner, .curved)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(sender: currentUser, messageId: String(messages.count + 1), sentDate: Date(), kind: .text(text))
        
        insertNewMessage(message)

        inputBar.inputTextView.text = ""
    }
}
