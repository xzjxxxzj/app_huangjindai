//
//  NewsView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/9.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class NewsView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var titileWidth: NSLayoutConstraint!
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var contentH: NSLayoutConstraint!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
}

extension NewsView {
    
    class func newsView() -> NewsView {
        return Bundle.main.loadNibNamed("NewsView", owner: nil, options: nil)?.first as! NewsView
    }
    
    func setTitle(_ titleString : String)
    {
        let stringFrame = PublicLib.countStringFrame(string: titleString, font: title.font)
        if stringFrame.width > 200 {
            titileWidth.constant = 200
        }else {
            titileWidth.constant = stringFrame.width + 10
        }
        title.text = titleString
    }
    
    func setContent(_ contentSting : String)
    {
        let stringH = PublicLib.countStringHeigh(string: contentSting, font: content.font, width: 200)
        content.numberOfLines = 0
        if stringH > 50 {
            contentH.constant = 50
        }else {
            contentH.constant = stringH
        }
        content.text = contentSting
    }
}

