//
//  ProfileTableViewController.swift
//  Messenger
//
//  Created by pop on 4/27/21.
//

import UIKit
import Alamofire


class ProfileTableViewController: UITableViewController {

    //Mark - IBoutlet
    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var SurnameLabel: UILabel!
    @IBOutlet weak var userIDLabel: UILabel!
    @IBOutlet weak var BioLabel: UILabel!
    
    var id: String = ""
    var profile = Profile()
    
    //Mark - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()

        getProfile(id: id)
        setupUI()
    }
    
    //Mark - Table View Delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            print("goto chat room")
        }
        
    }
    
    private func getProfile(id: String) {
        
        AF.request(Shared.url + "/user/contact?userid=" + id, method: .get)
            .response { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        do {
                            guard let fetchedData = response.data else { return }
                            let data = try JSONDecoder().decode(Profile.self, from: fetchedData)
                            
                            self.profile = data
                            
                            print(self.profile, 1)
                            
                            
                        } catch {
                            print("Cannot decode contact json")
                        }
                    default:
                        print("Failed to get profile")
                    }
                } else {
                    print("Cannot get into server")
                }
                
                debugPrint(response)
            }
        
    }
    
    //Mark- set up UI
    private func setupUI() {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            
            self.NameLabel.text = self.profile.name
            self.SurnameLabel.text = self.profile.surname
            self.userIDLabel.text = self.profile.userID
            self.StatusLabel.text = self.profile.status
            self.BioLabel.text = self.profile.bio
            
            self.tableView.reloadData()
        }
    }
}
