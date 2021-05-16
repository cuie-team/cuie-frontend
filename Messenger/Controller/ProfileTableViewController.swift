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
    
    override func viewWillAppear(_ animated: Bool) {
        
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            
            self.NameLabel.text = self.profile.name
            self.SurnameLabel.text = self.profile.surname
            self.userIDLabel.text = self.profile.userID
            self.StatusLabel.text = self.profile.status
            self.BioLabel.text = self.profile.bio
            if let path = self.profile.picpath {
                let url = URL(string: Shared.url + path)
                
                let imageView = UIImageView()
                imageView.kf.setImage(with: url)
                self.AvatarImageView.image =  imageView.image?.circleMasked
                
                //            cell.avatar.kf.setImage(with: url)
                //            cell.avatar.roundedImage()
            } else {
                self.AvatarImageView.image = UIImage(named: "avatar")
            }
            
            self.tableView.reloadData()
        }
    }
}
