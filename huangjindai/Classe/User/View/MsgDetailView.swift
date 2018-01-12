//
//  MsgDetailView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/6.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class MsgDetailView: UIWebView {
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
}

extension MsgDetailView {
    class func msgDetailView() -> MsgDetailView {
        return Bundle.main.loadNibNamed("MsgDetailView", owner: nil, options: nil)?.first as! MsgDetailView
    }
}
