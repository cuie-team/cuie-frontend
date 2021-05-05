//
//  ContactTableViewController.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import UIKit
import Foundation
import Alamofire

class ContactTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {

    //Mark - Vars
    
    private var allContact: UserContact = UserContact()
    private var filteredContact: [ContactInfo] = []
    
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
        return searchController.isActive ? filteredContact.count : allContact.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell

        let contact = searchController.isActive ? filteredContact[indexPath.row] : allContact.all[indexPath.row]
        
        cell.configure(contact: contact)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contacts = searchController.isActive ? filteredContact[indexPath.row] : allContact.all[indexPath.row]
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
        AF.request(Shared.url + "/user/contacts", method: .get)
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
        searchController.loadViewIfNeeded()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contact"
        searchController.searchResultsUpdater = self
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.scopeButtonTitles = ["All", "Professors", "Students", "Staffs"]
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func filteredContentForSearchText(searchText: String, scopeButton: String = "All") {
        if scopeButton == "Professors" {
            print(allContact.professors)
            filteredContact = allContact.professors.filter({ (contacts) -> Bool in
                return contacts.search(by: searchText)
            })
        } else if scopeButton == "Students" {
            filteredContact = allContact.students.filter({ (contacts) -> Bool in
                return contacts.search(by: searchText)
            })
        } else if scopeButton == "Staffs" {
            filteredContact = allContact.staffs.filter({ (contacts) -> Bool in
                return contacts.search(by: searchText)
            })
        } else {
            filteredContact = allContact.all.filter({ (contacts) -> Bool in
                return contacts.search(by: searchText)
            })
        }
        
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
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!

        filteredContentForSearchText(searchText: searchText.lowercased(), scopeButton: scopeButton)
    }
}
