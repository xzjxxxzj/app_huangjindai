//
//  SetInviteView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/13.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class SetInviteView: UIView {
    @IBOutlet weak var inviteCode: UITextField!
    @IBOutlet weak var setBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func setInviteView() -> SetInviteView {
        return  Bundle.main.loadNibNamed("SetInviteView", owner: nil, options: nil)?.first as! SetInviteView
    }
}
