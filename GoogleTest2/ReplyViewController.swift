//
//  ReplyViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/06/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import Foundation

class ReplyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet var professionLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var contentLabel : UILabel!
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var returnButton : UIButton!
    @IBOutlet var humanImageView : UIImageView!

    @IBOutlet var ReplyTableView: UITableView!
  
    
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
                
                print("name2: \(self.name)")
                print("profession2: \(self.targetProfession)")
                print("content2: \(self.content)")
                print("creatAt: \(String(describing: self.date))")
                
                
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
        
        //        nameLabel.text = String(db.collection("chats").document("displayname"))
    }
    override func viewDidLoad() {
        //nameLabel.text = nusiname
        super.viewDidLoad()
        fetchPosts()
        ReplyTableView.delegate = self
        ReplyTableView.dataSource = self
        ReplyTableView.register(UINib(nibName: "ReplyViewTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
    }
        
    private func fetchPosts() {
        fetchChat{[weak self] (posts, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let posts = posts {
                
                self?.posts = posts
                self?.ReplyTableView.reloadData()
            }
        }
    }
    
    func fetchChat(completion: @escaping ([One]?, Error?) -> Void) {
        db.collection("chats").document(cellId).collection("reply").getDocuments {(querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                var posts = [One]()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    print("creatAt2:\(String(describing: data["creatAt"]))")
                    print("photoURL2:\(String(describing: data["photoURL"]))")
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
                    print("posts:\(posts)")
                }
                completion(posts, nil)
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let replyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyViewTableViewCell", for: indexPath) as! ReplyViewTableViewCell
        let post = posts[indexPath.row]
        replyCell.create(name: post.displayName, content: post.text, userPhoto: post.photoURL, targetProfession: post.profession, id: replyId)
        print("replyId:\(replyId)")
        print("cellID:\(cellId)")
        cellIdArray.append(replyCell.cellId)
        replyCell.professional = post.profession
        
        return replyCell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count;
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
