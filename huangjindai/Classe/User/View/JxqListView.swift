//
//  JxqListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/25.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class JxqListView: UIView {
    @IBOutlet weak var allMoney: UILabel!
    @IBOutlet weak var danwei: UILabel!
    @IBOutlet weak var clickBtn: UIButton!
    @IBOutlet weak var laiyuan: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var conetentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func jxqListView() -> JxqListView {
        return Bundle.main.loadNibNamed("JxqListView", owner: nil, options: nil)?.first as! JxqListView
    }

}
