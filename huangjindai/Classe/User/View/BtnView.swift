//
//  BtnView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/10.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class BtnView: UIView {
    @IBOutlet weak var btnImage: UIImageView!
    
    @IBOutlet weak var btnName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func btnView() -> BtnView {
        return Bundle.main.loadNibNamed("BtnView", owner: nil, options: nil)?.first as! BtnView
    }
}
