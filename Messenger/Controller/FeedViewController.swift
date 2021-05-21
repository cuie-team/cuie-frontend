//
//  FeedViewController.swift
//  Messenger
//
//  Created by alongkot on 25/3/2564 BE.
//

import UIKit
import Foundation
import Alamofire
import Kingfisher

class FeedViewController: UITableViewController {
    
    var lastSelect: IndexPath?
    
    var feeds: [Feed] = []
    
    var pullControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        setupReload()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFeeds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        feeds = []
        tableView.reloadData()
    }
    
    private func setupReload() {
        pullControl = UIRefreshControl()
        pullControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.tableView.refreshControl = pullControl
    }
    
    //MARK: - setup pull down refersh action
    @objc func refresh(_ sender: AnyObject) {
        getFeeds {
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
    
}

extension FeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feed_cell", for: indexPath) as! FeedCell
        var dateText = ""
        
        if let msgTime = feeds[indexPath.row].posttime {
            let date = Date().textISOToDate(text: msgTime)
            let formatter = DateFormatter()
            
            if Calendar.current.isDateInToday(date) {
                formatter.dateFormat = "h:mm a"
                dateText = "Today, "
            } else {
                formatter.dateFormat = "dd MMM yyyy h:mm a"
            }
            
            dateText += "\(formatter.string(from: date))"
        }
        
        cell.date.text! = dateText
        
        cell.name.text! = "\(feeds[indexPath.row].senderName) \(feeds[indexPath.row].senderSurname)"
        
        if let avatarUrl = feeds[indexPath.row].senderPicpath {
            let path = URL(string: Shared.url + avatarUrl)
//            cell.avatar.kf.setImage(with: path)
//            cell.avatar.roundedImage()
            let imageView = UIImageView()
            imageView.kf.setImage(with: path)
            cell.avatar.image =  imageView.image?.circleMasked
        } else {
            cell.avatar?.image = UIImage(named: "avatar")
        }
        
        cell.caption.text! = feeds[indexPath.row].body
        cell.caption.numberOfLines = 0
        cell.caption.lineBreakMode = .byWordWrapping
        cell.caption.minimumScaleFactor = 0.8
        
        if let url = feeds[indexPath.row].filepath {
            let path = URL(string: Shared.url + url)
            cell.postedImage.kf.setImage(with: path)
        } else {
            cell.postedImage?.image = UIImage(named: "photoPlaceholder")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let type = AnimationType.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animation = ChatAnimation(self.tableView, animation: type)
        animation.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    private func getFeeds(successCompletion: @escaping () -> Void = { }, failedCompletion: @escaping () -> Void = { }) {
        
        AF.request(Shared.url + "/user/feeds", method: .get)
            .response { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        do {
                            guard let fetchedData = response.data else { return }
                            let data = try JSONDecoder().decode([Feed].self, from: fetchedData)
                            
                            self.feeds = data
                            
                            self.tableView.reloadData()
                            successCompletion()
                        } catch {
                            print("Cannot decode feed json")
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

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var postedImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commendTextField: UITextField!
    
    var isLiked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func likeAction(_ sender: UIButton) {
        if isLiked {
            sender.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        } else {
            sender.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        }
        isLiked.toggle()
    }
}
