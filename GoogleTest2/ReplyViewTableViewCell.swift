//
//  ReplyViewTableViewCell.swift
//  GoogleTest2
//
//  Created by 亀川敦躍 on 2023/08/26.
//

import UIKit

class ReplyViewTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var userPhotoImageView: UIImageView!
    @IBOutlet var professionLabel: UILabel!

    
    
    
    var cellId:String!
    var professional : String!
    var photoURL: String!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func create(name: String, content: String, userPhoto: String, targetProfession: String, id: String) {
        
        professional = targetProfession
        nameLabel.text = name
        contentLabel.text = content
        professionLabel.text = targetProfession
        cellId = id
        
        print(targetProfession)
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
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
            URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}
