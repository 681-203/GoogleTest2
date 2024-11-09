//
//  NagaraShowViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/12/16.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import Foundation

class NagaraShowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var professionLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var contentLabel : UILabel!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var returnButton : UIButton!
    @IBOutlet var humanImageView : UIImageView!
    @IBOutlet var newReplyTextView : UITextView!
    @IBOutlet var NagaraShowTableView: UITableView!
    @IBOutlet var forbidLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!

    
    let db = Firestore.firestore()
    var cellId = ""
    var replyId = UUID().uuidString
    var name = "name"
    var creatAt: Timestamp!
    var date: Date!
    var targetProfession = ""
    var content = ""
    var url = ""
    var posts = [One]()
    var cellIdArray = [String]()
    var replyContent :String!
    let user = Auth.auth().currentUser
    
    let photoURL = PhotoURL()
    
    
    
    @IBAction func deleteview() {
        print("name4: \(name)")
        self.dismiss(animated: false)
    }
    
    @IBAction func tapReplyButton() {
        Task { @MainActor in
            if let text = newReplyTextView.text,
               let user = user {
                let uid = user.uid
                do {
                    
                    let docRef = db.collection("users").document(uid)
                    let document = try await docRef.getDocument()
                    let id = document.documentID
                    let data = document.data()
                    let displayname = data?["displayName"] as? String ?? ""
                    let photoURL = data?["photoURL"] as? String ?? ""
                    let profession = data?["profession"] as? String ?? ""
                    
                    
                    try await setChat(text: text, uid, displayname, photoURL, profession)
                    
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
            } else {
                print("Unable to retrieve information r No text entered")
            }
        }
        replyContent = newReplyTextView.text
        db.collection("chats").document(cellId).collection("reply").document(replyId)
            .setData(["content" : newReplyTextView.text!]){ error in
                        if let error = error {
                            print("エラーが起きました")
                        } else {
                            print("ドキュメントが保存されました")
                        }
                }
       
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
        print("へprofession:\(targetProfession)")
        
        db.collection("chats").document(cellId).getDocument { [self] (document, error) in
            if let documents = document, documents.exists {
                
                self.name = documents.data()!["displayname"] as! String
                self.targetProfession = documents.data()!["targetProfession"] as! String
                self.content = documents.data()!["text"] as! String
                self.creatAt = documents.data()!["creatAt"] as? Timestamp
                self.date = self.creatAt.dateValue()
                self.url = documents.data()!["photoURL"] as! String
                
                
                guard let date2 = date else { return }
                print("date2:\(date2)")
                //                let unwraped = self.date!
                
                self.nameLabel.text = "\(self.name)"
                self.professionLabel.text = "\(self.targetProfession)"
                self.contentLabel.text = "\(self.content)"
                self.dateLabel.text = "\(String(describing: date2))"
                
                if let url2 = URL(string: url) {
                    photoURL.downloadImage(from: url2, userImage: self.humanImageView)
                }
                
            } else {
                print("Document does not exist")
            }
            
        }
        print("門司港行き")
        print(cellId)
        forbidLabel.isHidden = true
        returnButton.isHidden = false
        newReplyTextView.isHidden = false
        
        //        nameLabel.text = String(db.collection("chats").document("displayname"))
    }
    override func viewDidLoad() {
        //nameLabel.text = nusiname
        super.viewDidLoad()
        NagaraShowTableView.delegate = self
        NagaraShowTableView.dataSource = self
        NagaraShowTableView.register(UINib(nibName: "NagaraShowTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        fetchPosts()
    }
        
    private func fetchPosts() {
        fetchChat{[weak self] (posts, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let posts = posts {
                
                self?.posts = posts
                self?.NagaraShowTableView.reloadData()
            }
        }
    }
    
    func fetchChat(completion: @escaping ([One]?, Error?) -> Void) {
        let uid = user?.uid
        db.collection("chats").document(cellId).collection("reply").getDocuments {(querySnapshot, error) in
            if let error = error {
                completion(nil, error)
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
                        profession: data["profession"] as! String
                    )
                    posts.append(chat)
                }
                completion(posts, nil)
            }
        }
        
        let includes = db.collection("chats").document(cellId).collection("reply")
        print("名前",uid)
        includes.whereField("uid", isEqualTo: uid).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // `user`が含まれている場合の処理
                    print("ユーザーIDが含まれています")
                    self.forbidLabel.isHidden = false
                    self.returnButton.isHidden = true
                    self.newReplyTextView.isHidden = true
                } else {
                    // `user`が含まれていない場合の処理
                    
                    self.forbidLabel.isHidden = true
                    self.returnButton.isHidden = false
                    self.newReplyTextView.isHidden = false
                    print("ユーザーIDが含まれていません")
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let replyCell = tableView.dequeueReusableCell(withIdentifier: "NagaraShowTableViewCell", for: indexPath) as! NagaraShowTableViewCell
        let post = posts[indexPath.row]
        replyCell.create(name: post.displayName, content: post.text, userPhoto: post.photoURL, targetProfession: post.profession, id: replyId)
        cellIdArray.append(replyCell.cellId)
        replyCell.professional = post.profession
        
        return replyCell
        
    }
    
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
    }
    
    func setChat(text: String = "", _ uid: String = "", _ displayName: String = "", _ photoURL: String = "" , _ profession: String = "") async throws {
        if (text.isEmpty || uid.isEmpty || displayName.isEmpty || photoURL.isEmpty || profession.isEmpty ) {
            throw NSError(domain: "引数に空文字があります", code: -1, userInfo: nil)
        } else {
            let chatModel = ChatModel(text: text, uid: uid, displayname: displayName, photoURL: photoURL, creatAt: Date(), profession: profession)
            do {
                try db.collection("chats").document(cellId).collection("reply").document(replyId).setData(from: chatModel)
            } catch {
                throw NSError(domain: "データが保存できませんでした", code: -2, userInfo: nil)
            }
            self.dismiss(animated: true, completion: nil)
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
