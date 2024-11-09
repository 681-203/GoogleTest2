//
//  ViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/01/28.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore

class ViewController: UIViewController {
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapSoginButton(_ sender: Any) {
        print("ログインボタン押")
        auth()
    }

    private func auth() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] authentication, error in
            if let error = error {
                print("GIDSignInError: \(error.localizedDescription)")
                return
            }
            guard let user = authentication?.user,
                  let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase SignInError: \(error.localizedDescription)")
                } else {
                    self.login(authResult: authResult)
                }
            }
        }
    }

    private func login(authResult: AuthDataResult?) {
        print("ログイン完了")
        saveData(authResult: authResult)
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
}

