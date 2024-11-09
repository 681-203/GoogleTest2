//
//  MyPageViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2024/11/06.
//

import UIKit
import Firebase
import FirebaseFirestore

class MyPageViewController: UIViewController {
    
    @IBOutlet var dataTableView: UITableView!
    
    var db = Firestore.firestore()
    
    private func fetchPosts() {
        if search == "" {
            fetchChat{[weak self] (posts, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let posts = posts {
                    self?.posts = posts
                    self?.HyoujiTableView.reloadData()
                }
            }
        } else {
            fetchFilterChat{[weak self] (posts, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let posts = posts {
                    self?.posts = posts
                    self?.HyoujiTableView.reloadData()
                }
            }
        }
        
    }
    
    func fetchChat(completion: @escaping ([One]?, Error?) -> Void) {
        self.db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        
        db.collection("chats").getDocuments {(querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                print("Error getting documents: \(error)")
            } else {
                var posts = [One]()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let timestamp = data["creatAt"] as! Timestamp
                    let date = timestamp.dateValue()
                    let uidd = data["uid"] as! String
                    var trueDisplayname = data["displayname"] as! String
                    print("trueDN:",trueDisplayname)
                    self.db.collection("users").document(uidd).getDocument {(querySnapshot, error) in
                        if let error = error {
                            completion(nil,error)
                            print("Error getting documents")
                        } else {
                            
                        }
                        
                    }
                    
                    let chat = One(
                        id: data["id"] as! String,
                        text: data["text"] as! String,
                        displayName: data["displayname"] as! String,
                        photoURL: data["photoURL"] as! String,
                        creatAt: date,
                        profession: data["targetProfession"] as! String
                    )
                    print("\(document.documentID) => \(document.data())")
                    posts.append(chat)
                }
                completion(posts, nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
