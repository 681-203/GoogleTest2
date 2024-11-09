//
//  EmailLoginViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/04/29.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

@objc(EmailLoginViewController)
class EmailLoginViewController: UIViewController {
    
    var spinner: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        spinner = UIActivityIndicatorView(style: .large)
                spinner?.center = view.center
                view.addSubview(spinner!)
    }
    
    
    
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSpinner(completion: @escaping () -> Void) {
            spinner?.startAnimating()
            completion()
        }

        func hideSpinner(completion: @escaping () -> Void) {
            spinner?.stopAnimating()
            completion()
        }
    
    
    
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var mailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var signInButton : UIButton!
    
    var link : String!
    
    let db = Firestore.firestore()
    
    @IBAction func didTapSignInWithEmailLink(_ sender: AnyObject) {
        if let email = mailTextField.text {
          showSpinner {
            // [START signin_emaillink]
            Auth.auth().signIn(withEmail: email, link: self.link) { user, error in
              // [START_EXCLUDE]
              self.hideSpinner {
                if let error = error {
                  self.showMessagePrompt(error.localizedDescription)
                  return
                }
                self.navigationController!.popViewController(animated: true)
              }
              // [END_EXCLUDE]
            }
            // [END signin_emaillink]
          }
        } else {
          showMessagePrompt("Email can't be empty")
        }
      }
    
    @IBAction func didTapSendSignInLink(_ sender: AnyObject) {
        if let email = mailTextField.text {
            showSpinner {
                let actionCodeSettings = ActionCodeSettings()
                actionCodeSettings.url = URL(string: "https://myapp2-c9303.firebaseapp.com/__/auth/action?mode=action&oobCode=code")
                actionCodeSettings.handleCodeInApp = true
                actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                
                Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings) { error in
                    self.hideSpinner {
                        if let error = error {
                            self.showMessagePrompt(error.localizedDescription)
                            return
                        }
                        UserDefaults.standard.set(email, forKey: "Email")
                        self.showMessagePrompt("Check your email for the link")
                    }
                }
            }
        } else {
            showMessagePrompt("Email can't be empty")
        }
        
        
        
        
    }
    
    func saveData(authResult: AuthDataResult?) {
        guard let user = authResult?.user else { return }
        let data: [String: Any] = ["email": user.email ?? "", "displayName": user.displayName ?? "", "photoURL": user.photoURL?.absoluteString ?? "", "profession": ""]
        //ユーザー情報を保存し
        db.collection("users").document(user.uid).setData(data) { (error) in
            if let error = error {
                print("FirestoreInError: \(error.localizedDescription)")
                return
            }
            self.performSegue(withIdentifier: "toSelectViewController", sender: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
