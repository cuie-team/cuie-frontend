//
//  ContactTableViewController.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import UIKit
import Foundation
import Alamofire

class ContactTableViewController: UITableViewController, UISearchResultsUpdating {

    //Mark - Vars
    
    private var allContact: UserContact = UserContact()
    private var filteredContact: UserContact = UserContact()
    
    private let searchController = UISearchController(searchResultsController: nil)
    var pullControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupReload()
        tableView.tableFooterView = UIView()
        SetupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getContact()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
 
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredContact.student.count : allContact.student.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell

        let contact = searchController.isActive ? filteredContact.student[indexPath.row] : allContact.student[indexPath.row]
        
        cell.configure(contact: contact)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contacts = searchController.isActive ? filteredContact.student[indexPath.row] : allContact.student[indexPath.row]
        showUserProfile(contacts)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    //MARK: - setup pull down refersh action
    @objc func refresh(_ sender: AnyObject) {
        getContact {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.pullControl.endRefreshing()
                //To be implemented
            }
        } failedCompletion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.pullControl.endRefreshing()
                print("Failed to load data")
                //To be implemented
            }
        }
    }
    
    private func getContact(successCompletion: @escaping () -> Void = { }, failedCompletion: @escaping () -> Void = { }) {
        AF.request(Shared.url + "/users/contacts/info", method: .get)
            .response { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        do {
                            guard let fetchedData = response.data else { return }
                            let data = try JSONDecoder().decode(UserContact.self, from: fetchedData)
                            self.allContact = data
                            
                            self.tableView.reloadData()
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
        
        filteredContact.student = allContact.student.filter({ (contacts) -> Bool in
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
