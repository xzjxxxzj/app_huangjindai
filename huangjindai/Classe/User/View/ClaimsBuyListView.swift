//
//  ClaimsBuyListView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/8.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class ClaimsBuyListView: UIView {
    @IBOutlet weak var oneLabel: UILabel!
    @IBOutlet weak var towLabel: UILabel!
    @IBOutlet weak var threeLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func claimsBuyListView() -> ClaimsBuyListView {
        return Bundle.main.loadNibNamed("ClaimsBuyListView", owner: nil, options: nil)?.first as! ClaimsBuyListView
    }

}
