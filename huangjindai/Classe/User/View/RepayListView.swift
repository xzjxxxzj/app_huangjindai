//
//  RepayListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/28.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class RepayListView: UITableViewCell {
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var money: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func repayListView() -> RepayListView {
        return Bundle.main.loadNibNamed("RepayListView", owner: nil, options: nil)?.first as! RepayListView
    }
    
    func setStatus(_ statusData : Int) {
        if statusData == 1 {
            status.text = "已还"
            status.layer.borderWidth = 1
            status.layer.borderColor = UIColor(r: 204, g: 204, b: 204).cgColor
            status.textColor = UIColor(r: 204, g: 204, b: 204)
        } else if statusData == 2 {
            status.text = "提前"
            status.layer.borderWidth = 1
            status.layer.borderColor = UIColor(r: 241, g: 149, b: 147).cgColor
            status.textColor = UIColor(r: 241, g: 149, b: 147)
        } else {
            status.text = "未还"
            status.layer.borderWidth = 1
            status.layer.borderColor = UIColor(r: 176, g: 221, b: 250).cgColor
            status.textColor = UIColor(r: 176, g: 221, b: 250)
        }
    }
    
    func setName(_ type : Int) {
        if type == 0 {
            name.text = "利息"
            name.textColor = UIColor(r: 110, g: 204, b: 114)
        }else {
            name.text = "本息"
            name.textColor = UIColor(r: 243, g: 173, b: 103)
        }
    }
}
