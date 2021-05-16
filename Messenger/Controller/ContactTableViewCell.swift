//
//  ContactTableViewCell.swift
//  Messenger
//
//  Created by pop on 4/24/21.
//

import UIKit
import Alamofire

class ContactTableViewCell: UITableViewCell {

    //Mark: IBOutlets
    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var StatsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    func configure(contact: ContactInfo) {
        UsernameLabel.text = contact.name+" "+contact.surname
        StatsLabel.text = Shared.decodeStatus(status: contact.status)
        setAvatar(avatarLink: contact.picpath)
    }
    
    private func setAvatar(avatarLink: String?) {
        if let url = avatarLink {
            let path = URL(string: Shared.url + url)
            
            let imageView = UIImageView()
            imageView.kf.setImage(with: path)
            self.AvatarImageView.image =  imageView.image?.circleMasked
            
            //            cell.avatar.kf.setImage(with: url)
            //            cell.avatar.roundedImage()
        } else {
            self.AvatarImageView.image = UIImage(named: "avatar")
        }
    }
}
