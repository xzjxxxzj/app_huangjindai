//
//  WithdrawView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/21.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class WithdrawView: UIView {
    @IBOutlet weak var money: UITextField!
    @IBOutlet weak var userMoney: UILabel!
    @IBOutlet weak var allWith: UIButton!
    @IBOutlet weak var willTime: UILabel!
    @IBOutlet weak var clickBtn: UIButton!
    @IBOutlet weak var minMoney: UILabel!
    @IBOutlet weak var tishi: UILabel!
    @IBOutlet weak var tishiTitle: UILabel!
    @IBOutlet weak var tishiImage: UIImageView!
    @IBOutlet weak var fee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func withdrawView() -> WithdrawView {
        return Bundle.main.loadNibNamed("WithdrawView", owner: nil, options: nil)?.first as! WithdrawView
    }
}
