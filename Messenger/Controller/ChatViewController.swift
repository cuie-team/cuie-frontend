//
//  ChatViewController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet var chatTable: UITableView!
    
    let labels: [String] = ["Tim-Cook", "Emma", "Mark", "Pon-ek", "Li", "Emma"]
    var intervals: [Int] = [-123123, -1233, -24, -4564, -3455, -8767676723]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTable.tableFooterView = UIView()
        chatTable.delegate = self
        chatTable.dataSource = self
        intervals.sort(by: >)
        
        navigationItem.backButtonDisplayMode = .minimal
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let date = Date(timeIntervalSinceNow: TimeInterval(intervals[indexPath.row]))
        let formatter = DateFormatter()
        var dateText = ""
        
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            dateText = "Today, "
        } else {
            formatter.dateFormat = "MM/dd/yyyy"
        }
        
        dateText += "\(formatter.string(from: date))"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath) as! ChatViewCellController
        
        cell.name?.text = labels[indexPath.row]
        
        cell.detail?.text = "asdasdasdsad"
        cell.detail?.textColor = .secondaryLabel
        
        cell.date?.text = dateText
        cell.date?.textColor = .secondaryLabel
        
        if let image = UIImage(named: labels[indexPath.row]) {
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
        boardVC.title = labels[indexPath.row]
        
        navigationController?.pushViewController(boardVC, animated: true)
    }
    
}

class ChatViewCellController: UITableViewCell {
    @IBOutlet var avatar: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var detail: UILabel!
    @IBOutlet var date: UILabel!
}
