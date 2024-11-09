//
//  PhotoURLfunc.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/07/29.
//

import Foundation
import UIKit

class PhotoURL {
    func downloadImage(from url: URL, userImage: UIImageView) {
            getData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    userImage.image = UIImage(data: data)
                }
            }
    }
    // 画像の方を変換
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
