//
//  SettingsTableViewController.swift
//  Messenger
//
//  Created by pop on 2/15/21.
//

import UIKit
import Alamofire

class SettingsTableViewController: UITableViewController {

    //Mark: - IBOutlets
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    private var profile: Profile = Profile()
    
    //Mark: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setupUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setupUser()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getProfile()
    }
    
    //Mark - Tableview delegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        
        return headerView
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.0 : 10.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                profileAction()
            }
            else if (indexPath.row == 1) {
                detailAction()
            }
            else if (indexPath.row == 2) {
                termAction()
            }
        }
        else if (indexPath.section == 2) {
            if (indexPath.row == 1) {
                logoutAction()
            }
        }
    }
    
    
    private func profileAction() {
        
    }
    
    private func detailAction() {
        
    }
    
    private func termAction() {
        
    }
    
    private func logoutAction() {
        AF.request(Shared.url + "/signout", method: .post)
            .responseJSON { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        SocketIOManager.sharedInstance.closeConnection()
                        self.performSegue(withIdentifier: "unwindLogin", sender: self)
                    default:
                        self.presentAlert()
                    }
                } else {
                    print("Failed to connect with server")
                }
                
                debugPrint(response)
            }
    }
    
    //Prepare for returning to login view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindLogin" {
            guard let loginVC = segue.destination as? LoginViewController else { return }
            loginVC.PasswordTextField.text = ""
        } else if segue.identifier == "editProfile" {
            guard let editVC = segue.destination as? EditProfileTableViewController
            else { return }
            
            editVC.name = profile.name
            editVC.bio = profile.bio ?? ""
            editVC.surname = profile.surname
            editVC.image = avatarImage.image!
        }
    }
    
    //Mark - Update UI
    private func setupUser() {
        usernameLabel.text = "\(profile.name) \(profile.surname)"
        
        statusLabel.text = Shared.decodeStatus(status: profile.status) 
        
        if let path = profile.picpath {
            let url = URL(string: Shared.url + path)
            
            let imageView = UIImageView()
            imageView.kf.setImage(with: url)
            avatarImage.image =  imageView.image?.circleMasked
            
            //            cell.avatar.kf.setImage(with: url)
            //            cell.avatar.roundedImage()
        } else {
            avatarImage.image = UIImage(named: "avatar")
        }
        
        versionLabel.text = "Version 1.0.0"
        
        tableView.reloadData()
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Logout Failed", message: "Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func getProfile() {
        AF.request(Shared.url + "/user/contact", method: .get)
            .responseJSON { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
                        do {
                            guard let fetchedData = response.data else { return }
                            let data = try JSONDecoder().decode(Profile.self, from: fetchedData)
                            self.profile = data
                            
                            self.setupUser()
                        } catch {
                            print("Cannot decode profile json")
                        }
                    default:
                        print("failed to reqeust")
                    }
                } else {
                    print("Failed to connect with server")
                }
                
                debugPrint(response)
            }
    }
}
