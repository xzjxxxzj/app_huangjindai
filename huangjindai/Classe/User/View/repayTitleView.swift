//
//  repayTitleView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/27.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class RepayTitleView: UIView {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var nopay: UILabel!
    @IBOutlet weak var repay: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func repayTitleView() -> RepayTitleView {
        return Bundle.main.loadNibNamed("RepayTitleView", owner: nil, options: nil)?.first as! RepayTitleView
    }
}
