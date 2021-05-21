//
//  ChatViewController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit
import Alamofire
import Kingfisher

class ChatViewController: UIViewController {

    @IBOutlet var chatTable: UITableView!
    
    var pullControl: UIRefreshControl!
    
    var chatRooms: [ChatRoom] = []
    
    var isFirstLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        setupReload()
        setUpTable()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SocketIOManager.sharedInstance.getMessage { (_) in
            self.getChatRoom()
        }
        chatTable.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getChatRoom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        chatRooms = []
        chatTable.reloadData()
        isFirstLoad = true
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
    
    private func setUpTable() {
        chatTable.tableFooterView = UIView()
        chatTable.delegate = self
        chatTable.dataSource = self
        navigationItem.backButtonDisplayMode = .minimal
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroup))
    }
    
    @objc func createGroup() {
        guard let myVC = self.storyboard?.instantiateViewController(withIdentifier: "InviteVC") as? InviteViewController else { return }
        
        myVC.reload = {
            self.getChatRoom()
        }
        let navController = UINavigationController(rootViewController: myVC)
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    @objc private func getChatRoom(successCompletion: @escaping () -> Void = { }, failedCompletion: @escaping () -> Void = { }) {
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
                            print("Cannot decode chat json")
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
        
        let numberOfMembers = chatRooms[indexPath.row].roomType == "GROUP" ?
            " (\(chatRooms[indexPath.row].members.count))": ""
        
        cell.name?.text = (chatRooms[indexPath.row].name ?? "") + numberOfMembers
        
        cell.detail?.text = chatRooms[indexPath.row].lastMsgContext
        cell.detail?.textColor = .secondaryLabel
        
        cell.date?.text = dateText
        cell.date?.textColor = .secondaryLabel
        
        if let path = chatRooms[indexPath.row].getRoomImg() {
            let url = URL(string: Shared.url + path)
            
            let imageView = UIImageView()
            imageView.kf.setImage(with: url)
            cell.avatar.image =  imageView.image?.circleMasked
            
//            cell.avatar.kf.setImage(with: url)
//            cell.avatar.roundedImage()
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
        boardVC.roomID = chatRooms[indexPath.row].roomID
        
        navigationController?.pushViewController(boardVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isFirstLoad {
            let type = AnimationType.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
            let animation = ChatAnimation(chatTable, animation: type)
            animation.animate(cell: cell, at: indexPath, in: tableView)
        }
        if indexPath.row == 9 {
            isFirstLoad = false
        }
    }
}

class ChatViewCellController: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var detail: UILabel!
    @IBOutlet var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
