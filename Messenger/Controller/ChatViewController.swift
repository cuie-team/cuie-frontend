//
//  ChatViewController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit
import Alamofire

class ChatViewController: UIViewController {

    @IBOutlet var chatTable: UITableView!
    
    var pullControl: UIRefreshControl!
    
    let id: [String: Any] = ["sessionID": "12345", "chatroomID": "54321"]
    
    var chatRooms: [ChatRoom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        setupReload()
        chatTable.tableFooterView = UIView()
        chatTable.delegate = self
        chatTable.dataSource = self
        
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChatRoom()
        
        SocketIOManager.sharedInstance.establishConnection()
//        SocketIOManager.sharedInstance.connectToServerWithId(id: id)
        
        SocketIOManager.sharedInstance.testToServer()
    }
    
    //MARK: - setup pull down refersh action
    @objc func refresh(_ sender: AnyObject) {
        getChatRoom {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.pullControl.endRefreshing()
                //To be implemented
            }
        } failedCompletion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.pullControl.endRefreshing()
                print("Failed to load data")
                //To be implemented
            }
        }
    }
    
    private func setupReload() {
        pullControl = UIRefreshControl()
        pullControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.chatTable.refreshControl = pullControl
    }
    
    private func getChatRoom(successCompletion: @escaping () -> Void = { }, failedCompletion: @escaping () -> Void = { }) {
        AF.request(Shared.url + "/user/rooms", method: .get)
            .response { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        do {
                            guard let fetchedData = response.data else { return }
                            let data = try JSONDecoder().decode([ChatRoom].self, from: fetchedData)
                            self.chatRooms = data
                            
                            self.chatTable.reloadData()
                            successCompletion()
                        } catch {
                            print("Cannot decode contact json")
                        }
                    default:
                        failedCompletion()
                    }
                } else {
                    print("Cannot get into server")
                }
                
                debugPrint(response)
            }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath) as! ChatViewCellController
        var dateText = ""
        
        if let msgTime = chatRooms[indexPath.row].lastMsgTime {
            let date = Date().textISOToDate(text: msgTime)
            let formatter = DateFormatter()
            
            if Calendar.current.isDateInToday(date) {
                formatter.dateFormat = "HH:mm"
                dateText = "Today, "
            } else {
                formatter.dateFormat = "MM/dd/yyyy"
            }
            
            dateText += "\(formatter.string(from: date))"
        }
        
        cell.name?.text = chatRooms[indexPath.row].name
        
        cell.detail?.text = chatRooms[indexPath.row].lastMsgContext
        cell.detail?.textColor = .secondaryLabel
        
        cell.date?.text = dateText
        cell.date?.textColor = .secondaryLabel
        
        if let image = UIImage(named: chatRooms[indexPath.row].name) {
            cell.avatar?.image = image.circleMasked
        } else {
            cell.avatar?.image = UIImage(named: "avatar")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 76
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let boardVC = MessageBoardViewController()
        boardVC.title = chatRooms[indexPath.row].name
        
        navigationController?.pushViewController(boardVC, animated: true)
    }
    
}

class ChatViewCellController: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var detail: UILabel!
    @IBOutlet var date: UILabel!
}
