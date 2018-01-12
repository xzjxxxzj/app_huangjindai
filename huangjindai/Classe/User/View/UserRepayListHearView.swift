//
//  UserRepayListHearView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/30.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class UserRepayListHearView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userRepayListHearView() -> UserRepayListHearView {
        return Bundle.main.loadNibNamed("UserRepayListHearView", owner: nil, options: nil)?.first as! UserRepayListHearView
    }

}
