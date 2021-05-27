# cuie-frontend

# CUIE
## What is this app?
CUIE application is the variety app for CU engineering students. We could chat to friends, professors and staff. We also have feed views to keep up what's on trend right now in our university.
Many useful features provided in CUIE application.

## Description
We used MessageKit to build the interface of our chat view in MessageBoardController.swift. 
Main pages of the application is built with UITabBarController. Since we build chat app, we use socket.io to deal with the incoming message. 
The socket is written in Utils group. We use singleton design to deal capture an instance of our socket. 
We also use Alamofire library to call the APIs.

## Examples
### Socket.io
In Socket.swift file.
```swift
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

```
### Alamofire
Example APIs request in LoginViewController.swift
```swift
private func logIn() {
        let parameter = User(userID: StudentNumberTextField.text!, password: PasswordTextField.text!)

        let request = AF.request(Shared.url + "/signin", method: .post, parameters: parameter, encoder: JSONParameterEncoder.default)

        request.responseJSON { (response) in
            if let code = response.response?.statusCode {
                switch code {
                case 200:
                    SocketIOManager.sharedInstance.establishConnection()
                    self.createSpinnerView {
                        self.changeToHome()
                        SocketIOManager.sharedInstance.signin(user: parameter)
                    }
                default:
                    self.createSpinnerView {
                        self.presentAlert()
                    }
                }
            } else {
                print("Failed to connect with server")
            }

            debugPrint(response)
        }
       
    }
```
### MessageKit
How to setup our chatroom in MessageBoardController.swift
```swift
private func setCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        navigationItem.largeTitleDisplayMode = .never
    }
```

## Frameworks
* [Socket.io](https://github.com/socketio/socket.io-client-swift)

* [Alamofire](https://github.com/Alamofire/Alamofire)

* [MessageKit](https://github.com/MessageKit/MessageKit)

## Requirements
* iOS 13.0+
* Xcode 11+
* Swift 5.1+

