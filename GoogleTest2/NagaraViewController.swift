//
//  NagaraViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/12/09.
//

import UIKit
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn

class NagaraViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var db = Firestore.firestore()
    var posts = [One]()
    var hCellId: String!
    var hProfession: String!
    var cellIdArray = [String]()
    var userProfession:String!
    var search = ""
    var userProfession2 = ""
    //    var user: String?
    
    @IBOutlet private weak var NagaraTableView: UITableView!
    @IBOutlet private weak var searchField: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NagaraTableView.delegate = self
        NagaraTableView.dataSource = self
        searchField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            do {
                print("1:\(userProfession2)")
                
            }
            print("2:\(userProfession2)")
            fetchPosts()
            print("3:\(userProfession2)")
            
        }
        print("4:\(userProfession2)")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReply" {
            let replyView = segue.destination as! NagaraShowViewController
            replyView.cellId = hCellId
        }
        
    }
    
    func fetchChat(completion: @escaping ([One]?, Error?) -> Void) {
        self.db = Firestore.firestore()
        guard let user = Auth.auth().currentUser?.uid else { return }
        fetchProfession{ (pro, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.db.collection("chats").whereField("targetProfession", isEqualTo: pro).getDocuments {(querySnapshot, error) in
                    if let error = error {
                        
                        completion(nil, error)
                        print("Error getting documents: \(error)")
                        
                    } else {
                        var posts = [One]()
                        for document in querySnapshot!.documents {
                            
                            let data = document.data()
                            let timestamp = data["creatAt"] as! Timestamp
                            let date = timestamp.dateValue()
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
        }
    }
    
    
    
    func fetchPosts() {
        if search == "" {
            fetchChat{[weak self] (posts, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let posts = posts {
                    self?.posts = posts
                    self?.NagaraTableView.reloadData()
                }
            }
        } else {
            fetchFilterChat{[weak self] (posts, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let posts = posts {
                    self?.posts = posts
                    self?.NagaraTableView.reloadData()
                }
            }
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        let search = searchBar.text ?? ""
        self.search = search
        fetchPosts()
        // 入力された値がnilでなければif文のブロック内の処理を実行
        if let word = searchBar.text {
            //デバッグエリアに出力
            print("この値を検索します\(word)")
            
        }
        
    }
    
    func saveProfession () {
        self.db = Firestore.firestore()
    }
    
    
    
    func fetchFilterChat(completion: @escaping ([One]?, Error?) -> Void) {
        self.db = Firestore.firestore()
        print("searchはこれよ:\(search)")
        
        db.collection("chats").order(by: "text").start(at: [search]).end(at: [search + "\u{f8ff}"]).getDocuments {(querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                print("Error getting documents: \(error)")
            } else {
                var posts = [One]()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let timestamp = data["creatAt"] as! Timestamp
                    let date = timestamp.dateValue()
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

    
    func fetchProfession(completion: @escaping (String?, Error?) -> Void) {
        self.db = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(user).getDocument { [self] (document, error) in
            if let documents = document, documents.exists {
                self.userProfession = documents.data()!["profession"] as? String
                //userProfessionにcollection内のprofessionの値を保存
                completion(self.userProfession, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
    
    //任意のセルがタップされたときの処理
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NagaraTableViewCell", for: indexPath) as! NagaraTableViewCell
        let post = posts[indexPath.row]
        cell.create(name: post.displayName, content: post.text, userPhoto: post.photoURL, targetProfession: post.profession, id: post.id)
        cellIdArray.append(cell.cellId)
        cell.professional = post.profession
        
        
        
        return cell
    }
    
    //     セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    //cellに
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.dequeueReusableCell(withIdentifier: "NagaraTableViewCell", for: indexPath) as! NagaraTableViewCell
        hCellId = cellIdArray[indexPath.row]
        
        // アクションを実装
        performSegue(withIdentifier: "toReply", sender: nil)
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

