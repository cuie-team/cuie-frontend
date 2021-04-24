//
//  ChatViewController.swift
//  Messenger
//
//  Created by alongkot on 24/4/2564 BE.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet var chatTable: UITableView!
    
    let labels: [String] = ["John", "Emma", "Mickey", "Pon-ek", "Li"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatTable.delegate = self
        chatTable.dataSource = self
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath)
        cell.textLabel?.text = labels[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let boardVC = MessageBoardViewController()
        boardVC.title = labels[indexPath.row]
        
        navigationController?.pushViewController(boardVC, animated: true)
    }
    
}
