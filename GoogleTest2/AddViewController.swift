//
//  AddViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/02/11.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class AddViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
  
    var targetProfession: String? = "第二次産業"
    var dataList: [String] = ["第二次産業","公務員","第三次産業","第一次産業"]
    
    //PickerViewの設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        targetProfession = dataList[row]
        print("targetProfession1: \(targetProfession)")
//        guard let user = user else {return}
//        let targetProfession = db.collection("chats").document(user.uid)
//        targetProfession.updateData([
//            "targetProfession": dataList[row]
//        ])
        

    }
    
    
    @IBOutlet var soushinButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var textView: UITextView!
    @IBOutlet var selelctTargetPickerView: UIPickerView!
    
   
    
    @IBAction func tapCancelButton () {
        self.dismiss(animated: true)
    }
    
    @IBAction func tapSoushinButton (_ sender: Any) {
        Task { @MainActor in
            if let text = textView.text,
               let user = user, let targetProfession = targetProfession {
                let uid = user.uid
                
                do {
                    let docRef = db.collection("users").document(uid)
                    let document = try await docRef.getDocument()
                    let id = document.documentID
                    let data = document.data()
  
                    let displayname = data?["displayName"] as? String ?? ""
                    let photoURL = data?["photoURL"] as? String ?? ""
                    let profession = data?["profession"] as? String ?? ""
                    
                    
            
                    try await setChat(text: text, uid, displayname, photoURL, profession, targetProfession)
                } catch let error as NSError {
                    print("error: \(error.localizedDescription)")
                }
            } else {
                print("Unable to retrieve information r No text entered")
            }
        }
        
    }
    
    func setChat(text: String = "", _ uid: String = "", _ displayName: String = "", _ photoURL: String = "" , _ profession: String = "", _ targetProfession: String = "") async throws {
        if (text.isEmpty || uid.isEmpty || displayName.isEmpty || photoURL.isEmpty || profession.isEmpty || targetProfession.isEmpty ) {
            throw NSError(domain: "引数に空文字があります", code: -1, userInfo: nil)
        } else {
            let chatModel = ChatModel2(text: text, uid: uid, displayname: displayName, photoURL: photoURL, creatAt: Date(), profession: profession, targetProfession: targetProfession)
            do {
                try db.collection("chats").document(chatModel.id).setData(from: chatModel)
            } catch {
                throw NSError(domain: "データが保存できませんでした", code: -2, userInfo: nil)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.borderWidth = 3.0
        selelctTargetPickerView.delegate = self
        selelctTargetPickerView.dataSource = self
        
        
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

//extension AddViewController: UITextViewDelegate {
//
