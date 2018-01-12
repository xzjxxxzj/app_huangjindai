//
//  HomeStatusView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/20.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class HomeStatusView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
        
    }
}

extension HomeStatusView {
    class func homeStatusView() -> HomeStatusView {
        return Bundle.main.loadNibNamed("HomeStatusView", owner: nil, options: nil)?.first as! HomeStatusView
    }
}
