//
//  selectViewController.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/05/13.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn
import Foundation

class selectViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    let db = Firestore.firestore()
    let dataList = ["第二次産業","公務員","第三次産業","第一次産業"]
    let user = Auth.auth().currentUser
    
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var selectPickerView : UIPickerView!
    
    @IBAction func toNext() {
        performSegue(withIdentifier: "toNext", sender: nil)
    }
    
    override func viewDidLoad() {
        guard let user = user else {return}
        super.viewDidLoad()
        selectPickerView.delegate = self
        selectPickerView.dataSource = self
        let dataaaaa = ["profession" : "第二次産業"]
        db.collection("users").document(user.uid).updateData(dataaaaa) {(err) in
                if let err = err {
                    print("manager情報の保存に失敗しました\(err)")
                    return
                }
                print("manager情報の保存に成功しました")
            }
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    func pickerView(_ pickerView: UIPickerView,
                        titleForRow row: Int,
                        forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int, inComponent component: Int) {
        guard let user = user else {return}
        
        let profession = db.collection("users").document(user.uid)
        
        // Atomically add a new region to the "regions" array field.
        profession.updateData([
            "profession": dataList[row]
        ])
        print("あ:\(dataList[row])")
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


