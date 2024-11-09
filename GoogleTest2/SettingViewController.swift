//
//  SettingViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2024/02/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import GoogleSignIn

class SettingViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    
    @IBOutlet var displayNameLabel: UILabel!
    @IBOutlet var professionLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var returnButton: UIButton!
    
    @IBOutlet var newDisplayNameTextField: UITextField!
    @IBOutlet var newProfessionPickerView: UIPickerView!
    
    @IBAction func tapCancelButton (){
        self.dismiss(animated: true)
    }
    
    var posts = [One]()
    var content = ""
    let dataList = ["第二次産業","公務員","第三次産業","第一次産業"]
    var save = ""
    
    @IBOutlet var selectPickerView : UIPickerView!
    
    @IBAction func tapSoushinButton() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        let content: [String: Any] = ["displayName": newDisplayNameTextField.text]
        
        let content2: [String: Any] = ["profession": save ]
        print("ああ:\(String(describing: newDisplayNameTextField.text))")
        if newDisplayNameTextField.text != "" {
            db.collection("users").document(uid).updateData(content) { error in
                if let error = error {
                    print("エラーが発生しました: \(error.localizedDescription)")
                } else {
                    print("データが正常に書き込まれました")
                }
            }
        } else {
            print("doooooo")
            
        }
        
        db.collection("users").document(uid).updateData(content2) { error in
            if let error = error {
                print("エラーが発生しました: \(error.localizedDescription)")
            } else {
                print("データが正常に書き込まれました")
            }
        }
        
        self.dismiss(animated: true)
    }
    
    
    
    
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        super.viewDidLoad()
        selectPickerView.delegate = self
        selectPickerView.dataSource = self
        
        self.save = dataList[0]
        
        // Do any additional setup after loading the view.
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        guard let user = Auth.auth().currentUser?.uid else {return}
        
        
        // Atomically add a new region to the "regions" array field.
        self.save = dataList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
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
