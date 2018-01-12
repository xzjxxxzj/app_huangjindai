//
//  FinanceView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/9.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class FinanceView: UIView {
    @IBOutlet weak var zichan: UILabel!
    @IBOutlet weak var chongzhi: UIButton!
    @IBOutlet weak var tixian: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        setChongzhi()
        setTixian()
    }
    
    class func financeView() -> FinanceView {
        return Bundle.main.loadNibNamed("FinanceView", owner: nil, options: nil)?.first as! FinanceView
    }
    
    fileprivate func setChongzhi()
    {
        chongzhi.layer.cornerRadius = chongzhi.frame.height/2.0
        chongzhi.layer.borderWidth = 1
        chongzhi.layer.borderColor = UIColor.orange.cgColor
    }
    
    fileprivate func setTixian()
    {
        tixian.layer.cornerRadius = tixian.frame.height/2.0
        tixian.layer.borderWidth = 1
        tixian.layer.borderColor = UIColor.orange.cgColor
    }
}
