//
//  ViewController.swift
//  Messenger
//
//  Created by pop on 1/27/21.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    //Mark IBOutlets
    //Labels
    @IBOutlet weak var SignUpLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var StudentNumberTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var StatusTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var SurnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let status = ["Faculty member", "Researcher", "2nd Student", "3rd Student", "4th Student", "M.Eng", "Ph.D", "Administrative staff", "Labratory staff"]
    
    var statusPickerView = UIPickerView()
    
    //Buttons
    @IBOutlet weak var LogInButtonOutlet: UIButton!
    @IBOutlet weak var SignUpButtonOutlet: UIButton!
    @IBOutlet weak var ForgetPasswordButtonOutlet: UIButton!
    
    //Mark View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUIFor(login: true)
        
//        setupTextFieldDelegates()
        setupStyle()
        setupBackgroundTap()
        
        StatusTextField.inputView = statusPickerView
        
        statusPickerView.delegate = self
        statusPickerView.dataSource = self
        statusPickerView.tag = 1
        
        navigationController?.isNavigationBarHidden = true
        //Mark - back-end connection
        //3851d0eba9c7bd49509623b553133b5b9fbbe412
        
    }
    //Mark IBActions
    @IBAction func LogInButtonPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "Log In" {
            logIn()
            
        }
        if sender.titleLabel?.text == "Register" {
            signUp()
        }
    }
    
    @IBAction func ForgetPasswordButtonPressed(_ sender: Any) {
    }
    
    @IBAction func SingUpButtonPressed(_ sender: UIButton) {
        NameTextField.text! = ""
        SurnameTextField.text! = ""
        emailTextField.text! = ""
        StatusTextField.text! = ""
        
        updateUIFor(login: sender.titleLabel?.text == "Log In.")
        view.endEditing(false)
    }
    
    @IBAction func unwindLogin(segue: UIStoryboardSegue) { }

    private func setupBackgroundTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap(){
        view.endEditing(false)
    }
    
    
    //Mark Animation
    private func updateUIFor(login: Bool) {
        LogInButtonOutlet.setTitle( login ? "Log In" : "Register" , for: .normal)
        SignUpButtonOutlet.setTitle(login ? "Sign Up." : "Log In.", for: .normal)
        SignUpLabel.text = login ? "Don't have an account?" : "Have an acccount?"
        
        UIView.animate(withDuration: 0.5) {
            self.NameTextField.isHidden = login
            self.SurnameTextField.isHidden = login
            self.StatusTextField.isHidden = login
            self.emailTextField.isHidden = login
        }
    }
    
    private func setupStyle() {
        StudentNumberTextField.layer.cornerRadius = 5
        StudentNumberTextField.autocapitalizationType = .none
        StudentNumberTextField.autocorrectionType = .no
        
        PasswordTextField.layer.cornerRadius = 5
        PasswordTextField.autocapitalizationType = .none
        PasswordTextField.isSecureTextEntry = true
        PasswordTextField.autocorrectionType = .no
        
        StatusTextField.layer.cornerRadius = 5
        StatusTextField.autocapitalizationType = .none
        StatusTextField.autocorrectionType = .no
        
        NameTextField.layer.cornerRadius = 5
        NameTextField.autocapitalizationType = .none
        NameTextField.autocorrectionType = .no
        
        SurnameTextField.layer.cornerRadius = 5
        SurnameTextField.autocapitalizationType = .none
        SurnameTextField.autocorrectionType = .no
        
        emailTextField.layer.cornerRadius = 5
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        LogInButtonOutlet.layer.cornerRadius = 5
        SignUpButtonOutlet.layer.cornerRadius = 5
        
    }

}

extension LoginViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return status.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return status[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        StatusTextField.text = status[row]
        StatusTextField.resignFirstResponder()
    }
}

extension LoginViewController {
    private func signUp() {
        let registerParams: [String: String?] = [
            "name": NameTextField.text,
            "surname": SurnameTextField.text,
            "userID": StudentNumberTextField.text,
            "email": emailTextField.text,
            "password": PasswordTextField.text,
            "status": mapStatus(status: StatusTextField.text)
        ]
        let request = AF.request(Shared.url + "/signup", method: .post, parameters: registerParams, encoder: JSONParameterEncoder.default)
        
        request.responseJSON { (data) in
            if let code = data.response?.statusCode {
                switch code {
                case 200:
                    self.presentSuccessAlert()
                    self.updateUIFor(login: true)
                case 403:
                    self.presentDuplicatedAlert()
                default:
                    print("Failed to connect with server")
                }
            }
        }
        
        PasswordTextField.text! = ""
    }
    
    private func logIn() {
//        let parameter = User(userID: StudentNumberTextField.text!, password: PasswordTextField.text!)
        
        let parameter = User(userID: "6231341521", password: "passwordKongPonEk")

        let request = AF.request(Shared.url + "/signin", method: .post, parameters: parameter, encoder: JSONParameterEncoder.default)

        request.responseJSON { (response) in
            if let code = response.response?.statusCode {
                switch code {
                case 200:
                    SocketIOManager.sharedInstance.establishConnection()
                    self.createSpinnerView {
                        self.changeToHome()
                        SocketIOManager.sharedInstance.signin(user: parameter)
                    }
                default:
                    self.createSpinnerView {
                        self.presentAlert()
                    }
                }
            } else {
                print("Failed to connect with server")
            }

            debugPrint(response)
        }
       
    }
    
    
    private func changeToHome() {
        
        let board = UIStoryboard(name: "TabBarStoryboard", bundle: nil)
        guard let homeView = board.instantiateViewController(withIdentifier: "tabbar") as? TabBarController else { return }
        
        
        self.navigationController?.pushViewController(homeView, animated: true)
    }
    
    private func createSpinnerView(​_ completion: @escaping () -> Void) {
        let child = SpinnerViewController()
        
        // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        // wait three seconds to simulate some work happening
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            // then remove the spinner view controller
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
            completion()
        }
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Login Failed", message: "Id or password is incorrect.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentSuccessAlert() {
        let alert = UIAlertController(title: "Sign up successful", message: "You can now sign in with this account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func presentDuplicatedAlert() {
        let alert = UIAlertController(title: "Sign up failed", message: "This userID has already used.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func mapStatus(status: String?) -> String? {
        
        switch status {
        case "Researcher":
            return "professor"
        case "2nd Student":
            return "student2"
        case "3rd Student":
            return "student3"
        case "4th Student":
            return "student4"
        case "M.Eng":
            return "studentM"
        case "Ph.D":
            return "studentD"
        case "Administrative staff":
            return "staff"
        case "Labratory staff":
            return "staff"
        default:
            return nil
        }
    }
    
}
