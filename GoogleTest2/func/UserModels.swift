//  UserModels.swift
//  GoogleTest2
//  Created by 亀川敦躍 on 2023/02/11.
import Foundation
import UIKit
import FirebaseFirestore

public struct ChatModel: Codable, Identifiable {
    public var id = UUID().uuidString
    let text: String
    let uid: String
    let displayname: String
    let photoURL: String
    let creatAt: Date
    let profession: String
}

public struct ChatModel2: Codable, Identifiable {
    public var id = UUID().uuidString
    let text: String
    let uid: String
    let displayname: String
    let photoURL: String
    let creatAt: Date
    let profession: String
    let targetProfession: String
}

class One {
    var text: String
    var id: String
    var displayName: String
    var photoURL: String
    var creatAt: Date
    var profession: String
    
    
    
    init (id: String, text: String, displayName:String, photoURL:String, creatAt:Date, profession: String) {
        self.text = text
        self.id = id
        self.displayName = displayName
        self.photoURL = photoURL
        self.creatAt = creatAt
        self.profession = profession
    }
}


//〜〜〜〜〜〜〜〜〜〜〜〜以下は使用していないコード〜〜〜〜〜〜〜〜〜〜〜〜〜〜〜

