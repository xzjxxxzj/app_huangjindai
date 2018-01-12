//
//  HomeHuoqiView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/20.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class HomeHuoqiView: UIView {
    
    @IBOutlet weak var huoqiRate: UILabel!
    
    @IBOutlet weak var wanfenshouyi: UILabel!
    
    @IBOutlet weak var yestdayMoney: UILabel!
    
    @IBOutlet weak var huoqiButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
}

extension HomeHuoqiView {
    class func homeHuoqiView() -> HomeHuoqiView {
        return Bundle.main.loadNibNamed("HomeHuoqiView", owner: nil, options: nil)?.first as! HomeHuoqiView
    }
}
