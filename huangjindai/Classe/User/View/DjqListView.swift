//
//  DjqListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class DjqListView: UIView {
    @IBOutlet weak var conetentView: UIView!
    @IBOutlet weak var djqbutton: UIButton!
    @IBOutlet weak var canUseMoney: UILabel!
    @IBOutlet weak var laiyuan: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var useMoney: UILabel!
    @IBOutlet weak var allMoney: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func djqListView() -> DjqListView {
        return Bundle.main.loadNibNamed("DjqListView", owner: nil, options: nil)?.first as! DjqListView
    }
}
