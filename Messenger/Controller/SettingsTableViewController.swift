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
    
    //Mark: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupUser()
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
        print("profile")
    }
    
    private func detailAction() {
        print("detail")
    }
    
    private func termAction() {
        print("terms and conditions")
    }
    
    private func logoutAction() {
        AF.request(Shared.url + "/users/signout", method: .post)
            .responseJSON { (response) in
                if let code = response.response?.statusCode {
                    switch code {
                    case 200:
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
        }
    }
    
    //Mark - Update UI
    private func setupUser() {
        usernameLabel.text = "Pon-ek"
        
        statusLabel.text = "online"
        
        avatarImage.image = UIImage(named: "avatar")
        
        versionLabel.text = "Version 1.0.0"
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Logout Failed", message: "Please try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
