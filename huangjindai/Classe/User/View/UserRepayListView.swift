//
//  UserRepayListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/30.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SwiftyJSON
fileprivate var listNum :CGFloat = 0
fileprivate let listH : CGFloat = 40

class UserRepayListView: UIView {
    @IBOutlet weak var list: UIView!
    @IBOutlet weak var btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listNum = 0
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func userRepayListView() -> UserRepayListView {
        return Bundle.main.loadNibNamed("UserRepayListView", owner: nil, options: nil)?.first as! UserRepayListView
    }
    
    public func setList(_ time : String , _ money : String, _ type : Int, _ status : Int)
    {
        let H : CGFloat = listNum * listH
        listNum = listNum + 1.0
        let view = RepayListView.repayListView()
        view.time.text = time
        view.money.text = money
        view.setName(type)
        view.setStatus(status)
        view.frame = CGRect(x: 0, y: H, width: kMobileW, height: listH)
        list.addSubview(view)
    }
}
