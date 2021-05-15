//
//  FeedViewController.swift
//  Messenger
//
//  Created by alongkot on 25/3/2564 BE.
//

import UIKit
import Foundation

class FeedViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var lastSelect: IndexPath?
    
    let feeds: [Feed] = [
        Feed(name: "Pon-ek", date: "11 Nov 2012 1:20 PM.", description: "dasdasdasdasdasddasdasdasdasdasddasdasdasdasdasddasdasdasdasdasddasdasdasdasdasddasdasdasdasdasd", image: UIImage(named: "avatar")!),
        Feed(name: "Li", date: "11 Nov 2012 1:20 PM.", description: "dasdasd", image: UIImage(named: "avatar")!),
        Feed(name: "Alongkot", date: "11 Nov 2012 1:20 PM.", description: "asdasdasdasdasd", image: UIImage(named: "avatar")!),
        Feed(name: "Pon-ek", date: "11 Nov 2012 1:20 PM.", description: "asdasdasdasdasd", image: UIImage(named: "photoPlaceholder")!),
        Feed(name: "Li", date: "11 Nov 2012 1:20 PM.", description: "asdasdasdasdasd", image: UIImage(named: "photoPlaceholder")!),
        Feed(name: "Pon-ek", date: "11 Nov 2012 1:20 PM.", description: "asdasdasdasdasd", image: UIImage(named: "photoPlaceholder")!),
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self

    }

}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feed_cell", for: indexPath) as! FeedCell
        
        cell.name?.text = feeds[indexPath.row].name
        cell.date?.text = feeds[indexPath.row].date
        cell.avatar?.image = feeds[indexPath.row].image
        cell.detail?.text = feeds[indexPath.row].description
        cell.detail?.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        
        cell.selectionStyle = .none
        
        cell.detail?.isHidden = false
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FeedCell
        
        cell.selectionStyle = .none
        
        cell.detail?.isHidden = true
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath) {
            return 103
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let type = AnimationType.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animation = ChatAnimation(self.tableView, animation: type)
        animation.animate(cell: cell, at: indexPath, in: tableView)
    }
    
}

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var detail: UILabel!
}
