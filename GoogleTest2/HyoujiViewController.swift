//
//  HyoujiViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/02/11.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn


//ここまで

class HyoujiViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var db = Firestore.firestore()
    var posts = [One]()
    var hCellId: String!
    var hProfession: String!
    var cellIdArray = [String]()
    var search = ""
    
    
    
    @IBOutlet private weak var HyoujiTableView: UITableView!
    @IBOutlet private weak var searchField: UISearchBar!
    @IBOutlet var settingButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBAction func ToNextView() {
        performSegue(withIdentifier: "toAddViewController", sender: nil)
    }
    
    @IBAction func ToSettingButton() {
        performSegue(withIdentifier: "toSettingViewController", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        HyoujiTableView.delegate = self
        HyoujiTableView.dataSource = self
        searchField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPosts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReply" {
            let replyView = segue.destination as! ReplyViewController
            replyView.cellId = hCellId
            print("The journey",hCellId)
        }
    }
    
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
    
    
    
    func fetchFilterChat(completion: @escaping ([One]?, Error?) -> Void) {
        self.db = Firestore.firestore()
        let kensaku = db.collection("chats").order(by: "text").start(at: [search]).end(at: [search + "\u{f8ff}"])
        print("searchはこれよ:\(search)")
        kensaku.getDocuments {(querySnapshot, error) in
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
    //任意のセルがタップされたときの処理
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HyoujiTableViewCell", for: indexPath) as! HyoujiTableViewCell
        let post = posts[indexPath.row]
        cell.create(name: post.displayName, content: post.text, userPhoto: post.photoURL, targetProfession: post.profession, id: post.id)
        cellIdArray.append(cell.cellId)
        cell.professional = post.profession
        print("熊本",posts)
        
        
        return cell
    }
    
    //     セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    //cellに
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.dequeueReusableCell(withIdentifier: "HyoujiTableViewCell", for: indexPath) as! HyoujiTableViewCell
        hCellId = cellIdArray[indexPath.row]
        
        // アクションを実装
        performSegue(withIdentifier: "toReply", sender: nil)
    }
    
    
    
    
}





//class HyoujiViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }




/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */


