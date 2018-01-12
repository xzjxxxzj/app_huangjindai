//
//  InviteView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/13.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class InviteView: UIView {
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var code: UIButton!
    @IBOutlet weak var detailBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        setImageBack()
    }
    
    class func inviteView() -> InviteView {
        return  Bundle.main.loadNibNamed("InviteView", owner: nil, options: nil)?.first as! InviteView
    }
    
    fileprivate func setImageBack()
    {
        imageView.backgroundColor = UIColor(patternImage: UIImage(named: "inviteBg")!)
    }
    
    func setLink(_ linkString : String)
    {
        link.text = linkString
        image.image = PublicLib.createQRForString(qrString: linkString, qrImageName: "")
    }
}
