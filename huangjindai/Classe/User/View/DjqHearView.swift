//
//  DjqHearView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class DjqHearView: UIView {
    @IBOutlet weak var canUse: UILabel!
    @IBOutlet weak var use: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func djqHearView() -> DjqHearView {
        return Bundle.main.loadNibNamed("DjqHearView", owner: nil, options: nil)?.first as! DjqHearView
    }
}
