//
//  PasswordViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2024/11/02.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class PasswordViewController: UIViewController {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var mailTextField: UITextField!
        @IBOutlet var userNameTextField: UITextField!
        @IBOutlet var signInButton: UIButton!
        @IBOutlet var createButton: UIButton!

        let db = Firestore.firestore()

        override func viewDidLoad() {
            super.viewDidLoad()
            // ここに初期化コードを追加
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }

    @IBAction func didTapEmailLogin(_ sender: AnyObject) {
        guard let email = mailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showMessagePrompt("Email and Password can't be empty")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                // メールアドレスが既に使用されている場合はサインインを試みる
                Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                    if let error = error {
                        self.showMessagePrompt("サインインに失敗しました: \(error.localizedDescription)")
                        return
                    }
                    if let user = authResult?.user {
                        print("サインインに成功しました", user.email!)
                        print(authResult)
                        self.saveUserData(authResult: authResult)
                        
                    }
                }
            } else if let error = error {
                self.showMessagePrompt("登録に失敗しました: \(error.localizedDescription)")
                return
            }
            if let user = authResult?.user {
                print("登録に成功しました", user.email!)
                self.saveUserData(authResult: authResult)
            }
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
    func showMessagePrompt(_ message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    
    func saveUserData(authResult: AuthDataResult?) {
        guard let user = authResult?.user else { return }
        print("南今庄")
        let data: [String: Any] = ["email": user.email ?? "", "displayName": user.displayName ?? "", "photoURL": user.photoURL?.absoluteString ?? "", "profession": ""]
        print("今庄")
        //ユーザー情報を保存し
        db.collection("users").document(user.uid).setData(data) { (error) in
            if let error = error {
                print("FirestoreInError: \(error.localizedDescription)")
                return
            }
            print("湯尾")
            self.performSegue(withIdentifier: "toSelectFromPassword", sender: nil)
            print("南条")
        }
    }

}
