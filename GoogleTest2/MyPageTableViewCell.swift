//
//  MyPageTableViewCell.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2024/11/06.
//

import UIKit

class MyPageTableViewCell: UITableViewCell {
    
    @IBOutlet  private weak var nameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet  private weak var professionLabel: UILabel!
    @IBOutlet var replyTableView: UITableView!
    
    var cellId: String!
    var professional: String!
    
    func create(name: String, content: String, userPhoto: String, targetProfession: String, id: String) {
        nameLabel.text = name
        contentLabel.text = content
        professionLabel.text = targetProfession
        cellId = id
        professional = targetProfession
        if let url = URL(string: userPhoto) {
            downloadImage(from: url, userImage: userPhotoImageView)
        }

    }
    
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
