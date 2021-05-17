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

class InviteTableViewCell: UITableViewCell {
    //Mark: IBOutlets
    @IBOutlet weak var AvatarImageView: UIImageView!
    @IBOutlet weak var UsernameLabel: UILabel!
    @IBOutlet weak var StatsLabel: UILabel!
    @IBOutlet weak var check: UIImageView!
    
    var id: String = ""
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            check.image = UIImage(systemName: "checkmark.circle.fill")
            check.setImageColor(color: UIColor.systemGreen)
        } else {
            check.image = UIImage(systemName: "circle")
            check.setImageColor(color: UIColor.lightGray)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(contact: ContactInfo) {
        UsernameLabel.text = contact.name+" "+contact.surname
        StatsLabel.text = Shared.decodeStatus(status: contact.status)
        setAvatar(avatarLink: contact.picpath)
        id = contact.userID
        self.selectionStyle = .none
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
