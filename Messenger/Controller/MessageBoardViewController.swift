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
    
    let chatroom: ChatRoom = ChatRoom()
    
    var currentUser: Sender!
    
    var otherUser: Sender!
    
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUser()
        getMessage()
        setCollectionView()
        setInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setChatRoom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        chatroom.stopChatSession()
    }
    
    private func setChatRoom() {
        chatroom.setupNetworkCommunication()
        chatroom.joinChat(userName: currentUser.displayName, otherName: otherUser.displayName)
        chatroom.delegate = self
    }
    
    private func setUser() {
        self.currentUser = Sender(senderId: "self", displayName: "Tim-Cook")
        self.otherUser = Sender(senderId: "other", displayName: title ?? "Unknown")
    }
    
    private func getMessage() {
        messages.append(Message(
                            sender: currentUser,
                            messageId: UUID().uuidString,
                            sentDate: Date().addingTimeInterval(-96400),
                            kind: .text("Hello!!")))
        
        messages.append(Message(
                            sender: otherUser,
                            messageId: UUID().uuidString,
                            sentDate: Date().addingTimeInterval(-86200),
                            kind: .text("How's it going")))
        
        messages.append(Message(
                            sender: currentUser,
                            messageId: UUID().uuidString,
                            sentDate: Date().addingTimeInterval(-6400),
                            kind: .text("Covid19 spreading")))
        
        messages.append(Message(
                            sender: currentUser,
                            messageId: UUID().uuidString,
                            sentDate: Date().addingTimeInterval(-6200),
                            kind: .text("Sad")))
    }
    
    private func setCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setInputBar() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] (_) in
            self?.presentInputActionSheet()
        }
        
        messageInputBar.delegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] (_) in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { (_) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { (_) in
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
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

extension MessageBoardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: -setup UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let _ = image.pngData() else { return }
        
        //Upload image
        //Send image
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
    //
    
    //MARK: - setup for MessageLayoutDelegate
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return .zero
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if let image = UIImage(named: message.sender.displayName) {
            avatarView.image = image
        } else {
            avatarView.image = UIImage(named: "avatar")
        }
        
        if indexPath.section == 0 { avatarView.isHidden = false }
        else {
            let isSameSender = message.sender.senderId == messages[indexPath.section - 1].sender.senderId
            
            if isSameSender {
                let interval = message.sentDate.timeIntervalSinceReferenceDate - messages[indexPath.section - 1].sentDate.timeIntervalSinceReferenceDate
                
                if interval < 300 {
                    avatarView.isHidden = true
                } else {
                    avatarView.isHidden = false
                }
            } else {
                avatarView.isHidden = false
            }
        }
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 35
        } else {
            let interval = message.sentDate.timeIntervalSinceReferenceDate - messages[indexPath.section - 1].sentDate.timeIntervalSinceReferenceDate
            
            if interval < 300 {
                return 0
            }
            return 35
        }
        
    }
    //
    
    
    //MARK: - setup for MessagesDisplayDelegate
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        switch message.kind {
        case .text(_):
            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            
            if indexPath.section == 0 { return .bubbleTail(corner, .curved) }
            else {
                let isSameSender = message.sender.senderId == messages[indexPath.section - 1].sender.senderId
                
                if isSameSender {
                    let interval = message.sentDate.timeIntervalSinceReferenceDate - messages[indexPath.section - 1].sentDate.timeIntervalSinceReferenceDate
                    
                    if interval < 300 {
                        return .bubble
                    } else {
                        return .bubbleTail(corner, .curved)
                    }
                    
                } else {
                    return .bubbleTail(corner, .curved)
                }
            }
        default:
            return .bubble
        }
        
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            imageView.image = media.image
        default:
            break
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let formatter = DateFormatter()
        var date = ""
        
        if Calendar.current.isDateInToday(message.sentDate) {
            formatter.dateFormat = "HH:mm"
            date = "Today, "
        } else {
            formatter.dateFormat = "MM/dd/yyyy, HH:mm"
        }
        
        
        if indexPath.section == 0 {
            date = formatter.string(from: message.sentDate)
        } else {
            let interval = message.sentDate.timeIntervalSinceReferenceDate - messages[indexPath.section - 1].sentDate.timeIntervalSinceReferenceDate
            
            if interval < 300 {
                return nil
            }
            
            date += "\(formatter.string(from: message.sentDate))"
        }
        
        return NSAttributedString(
            string: date,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
    //
    
    //MARK: - setup for InputBarAccessoryViewDelegate
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        let message = Message(sender: currentUser, messageId: String(messages.count + 1), sentDate: Date(), kind: .photo(Media(url: nil, image: UIImage(named: "Tim-Cook"), placeholderImage: UIImage(named: "Tim-Cook")!, size: CGSize(width: 250, height: 200))))
        
        //insertNewMessage(message)
        chatroom.send(message: text)

        inputBar.inputTextView.text = ""
    }
    //
    
}

extension MessageBoardViewController: MessageCellDelegate {
    //MARK: -setup for MessageCellDelegate
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(_):
            let vc = PhotoViewerController()
            vc.hidesBottomBarWhenPushed = true
            vc.title = "Photo"
            
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
}

extension MessageBoardViewController: ChatRoomDelegate {
    func receive(message: Message) {
        insertNewMessage(message)
    }
}
