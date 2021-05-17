//
//  InviteViewController.swift
//  Messenger
//
//  Created by alongkot on 17/5/2564 BE.
//

import UIKit
import Alamofire

class InviteViewController: UITableViewController {
    
    private var allContact: UserContact = UserContact()
    private var filteredContact: [ContactInfo] = []
    private var selectedProfile: Profile = Profile()
    
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
        filteredContact = []
        tableView.reloadData()
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    private func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as! InviteTableViewCell
        
        let contact = searchController.isActive ? filteredContact[indexPath.row] : allContact.all[indexPath.row]
        
        cell.configure(contact: contact)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contacts = searchController.isActive ? filteredContact[indexPath.row] : allContact.all[indexPath.row]
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredContact.count : allContact.all.count
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let type = AnimationType.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.3, delayFactor: 0.05)
        let animation = ChatAnimation(tableView, animation: type)
        animation.animate(cell: cell, at: indexPath, in: tableView)
    }

}

extension InviteViewController: UISearchResultsUpdating, UISearchBarDelegate {
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
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        
        filteredContentForSearchText(searchText: searchText.lowercased(), scopeButton: scopeButton)
    }
    
}
