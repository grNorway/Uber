//
//  ViewController.swift
//  Uber
//
//  Created by Panagiotis Siapkaras on 7/23/17.
//  Copyright © 2017 Panagiotis Siapkaras. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func topButton(_ sender: UIButton) {
        
        if let email = emailTextField.text , let password = passwordTextField.text {
            
            if signUpMode {
                
                //Do signUp
                
                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                    
                    if let error = error {
                        self.alertError(error: error.localizedDescription)
                        return
                    }else{
                        
                        if self.riderDriverSwitch.isOn{
                            //Driver
                            let request = Auth.auth().currentUser?.createProfileChangeRequest()
                            request?.displayName = "Driver"
                            request?.commitChanges(completion: nil)
                            print("switch.isOn")
                        }else{
                            //rider
                            print("switch.isOff")
                            let request = Auth.auth().currentUser?.createProfileChangeRequest()
                            request?.displayName = "Rider"
                            request?.commitChanges(completion: nil)
                            self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                        }
                        
                    }
                    
                })
                
            }else{
                
                //Do Login
                
                Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                    if let error = error {
                        self.alertError(error: error.localizedDescription)
                        return
                    }else{
                        if user?.displayName == "Driver"{
                            
                            self.performSegue(withIdentifier: "DriverSegue", sender: nil)
                            //print("Driver")
                        }else{
                            //print("Rider")
                            self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                        }
                        
                    }
                })
                
            }
            
        }else {
            showEmptyTextFields()
        }
        
    }

    func alertError(error : String){
    
        let alert = UIAlertController(title:"Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            
            self.dismiss(animated:true , completion: nil)
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    
    }
    
    func showEmptyTextFields(){
        let alert = UIAlertController(title: "Error", message: "You must have inputs at the email or password", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func bottomButton(_ sender: UIButton) {
        
        if signUpMode {
            //do signup stuff
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            signUpMode = false
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            print(signUpMode)
        }else{
            //do login stuff
            
            topButton.setTitle("Sign Up", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            signUpMode = true
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            
            print(signUpMode)
        }
        
    }
}

