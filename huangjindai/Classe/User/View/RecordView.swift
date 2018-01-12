//
//  RecordView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/9.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class RecordView: UIView {
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var leftMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func recordView() -> RecordView {
        return Bundle.main.loadNibNamed("RecordView", owner: nil, options: nil)?.first as! RecordView
    }
}
