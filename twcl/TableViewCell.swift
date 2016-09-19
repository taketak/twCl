//
//  TableViewCell.swift
//  twcl
//
//  Created by 武内駿 on 2016/09/19.
//  Copyright © 2016年 Syun Takeuchi. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var profileimage: UIImageView!
    
    @IBOutlet weak var tweettext: UILabel!
    //名前セット
    func setUsername(name:String){
        user.text = name
    }
    //プロフィール画像セット
    func setUserprofileimage(url:String){
        let imageurl:NSURL = NSURL(string: url)!
        let imgdata: NSData = NSData(contentsOfURL: imageurl)!
        self.profileimage.image = UIImage(data: imgdata)
    }
    //ツイート内容セット
    //小文字だとobjective-Cの関数と名前が被る
    func setTweetText(text:String){
        tweettext.text = text
    }
    
}
