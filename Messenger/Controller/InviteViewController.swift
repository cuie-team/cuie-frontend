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
    
    var selectedId: [String: Bool] = [:]
    
    var reload: () -> Void = {}
    
    var countSelect: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTable()
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
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let create = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(presentGroupNameAlert))
                
        navigationItem.rightBarButtonItem = create
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func getSuccessAlert() {
        let alert = UIAlertController(title: "Created sucessful", message: "Let's talk!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (_) in
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.reload()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentGroupNameAlert() {
        let ids = getSelectedId()
        
        let alert = UIAlertController(title: "Create your group's name", message: "Enter group name", preferredStyle: .alert)
        alert.addTextField { (textfield) in
            textfield.text = ""
            textfield.placeholder = "Type group name"
        }
        alert.addAction(UIAlertAction(title: "Let's chat!", style: .default, handler: { (_) in
            let textField = alert.textFields![0]
            self.createGroup(name: textField.text!, targetIDs: ids)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)
    }
   
    private func createGroup(name: String, targetIDs: [String]) {
        let parameter: CreateGroupBody = CreateGroupBody(name: name, targetIDs: targetIDs)
        
        AF.request(Shared.url + "/user/room/group", method: .post, parameters: parameter, encoder: JSONParameterEncoder.default)
            .response { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        self.getSuccessAlert()
                    default:
                        print("failed to create group")
                    }
                } else {
                    print("Cannot get into server")
                }

                debugPrint(response)
                
            }
    }
    
    private func goChat(name: String, roomID: String) {
        let boardVC = MessageBoardViewController()
        boardVC.title = name
        boardVC.roomID = roomID
        
        navigationController?.pushViewController(boardVC, animated: true)
    }
    
    private func getSelectedId() -> [String] {
        var ids: [String] = []
        selectedId.forEach { (id, bool) in
            if bool {
                ids.append(id)
            }
        }
        return ids
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as! InviteTableViewCell
        
        let contact = searchController.isActive ? filteredContact[indexPath.row] : allContact.all[indexPath.row]
        
        cell.configure(contact: contact)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InviteTableViewCell
        else { return }
        
        selectedId[cell.id]? = true
        countSelect += 1
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? InviteTableViewCell
        else { return }
        
        selectedId[cell.id]? = false
        countSelect -= 1
        if countSelect == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
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
                            
                            self.setIdDict(contacts: self.allContact.all)
                            
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
    
    private func setIdDict(contacts: [ContactInfo]) {
        if selectedId.count == 0 {
            contacts.forEach { (contact) in
                selectedId[contact.userID] = false
            }
        }
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

struct CreateGroupBody: Codable {
    let name: String
    let targetIDs: [String]
}
