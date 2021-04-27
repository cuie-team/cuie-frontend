//
//  ContactTableViewController.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import UIKit
import Foundation

class ContactTableViewController: UITableViewController, UISearchResultsUpdating {

    //Mark - Vars
    
    private var allContact: [ContactInfo] = []
    private var filteredContact: [ContactInfo] = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    var pullControl: UIRefreshControl!
    
    private let contacts: [ContactInfo] = [
        ContactInfo(name: "Tee", surname: "lert", status: "4th yrs", userID: "6030293121", email: "tee101@gmail.com"),
        ContactInfo(name: "Pun", surname: "thana", status: "4th yrs", userID: "6030024721", email: "Pun101@gmail.com"),
        ContactInfo(name: "Aj", surname: "P", status: "Faculty member", userID: "603012341", email: "Aj101@gmail.com")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReload()
        tableView.tableFooterView = UIView()
        SetupSearchController()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
 
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredContact.count : allContact.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell

        let contact = searchController.isActive ? filteredContact[indexPath.row] : allContact[indexPath.row]
        
        cell.configure(contact: contact)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contacts = searchController.isActive ? filteredContact[indexPath.row] : allContact[indexPath.row]
        showUserProfile(contacts)
        
    }
    
    //MARK: - setup pull down refersh action
    @objc func refresh(_ sender: AnyObject) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.allContact = self.contacts
            self.tableView.reloadData()
            self.pullControl.endRefreshing()
        }
    }
    
    private func setupReload() {
        pullControl = UIRefreshControl()
        pullControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.tableView.refreshControl = pullControl
    }
    
    //Mark - set up searching contact
    private func SetupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contact"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        
    }
    private func filteredContentForSearchText(searchText: String) {
        
        filteredContact = allContact.filter({ (contacts) -> Bool in
            return contacts.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    //Mark - Navigation
    private func showUserProfile(_ contact: ContactInfo) {
        
        let board = UIStoryboard(name: "TabBarStoryboard", bundle: nil)
        guard let profileView = board.instantiateViewController(identifier: "ProfileView") as? ProfileTableViewController else { return }
        
        profileView.contact = contact
        self.navigationController?.pushViewController(profileView, animated: true)
    }
    
}

extension ContactTableViewController {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
