//
//  InviteInvestView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/14.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

class InviteInvestView: UIView {
    @IBOutlet weak var oneName: UILabel!
    @IBOutlet weak var towName: UILabel!
    @IBOutlet weak var threeName: UILabel!
    @IBOutlet weak var fourName: UILabel!
    @IBOutlet weak var endName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = UIViewAutoresizing()
    }
    
    class func inviteInvestView() -> InviteInvestView {
        return  Bundle.main.loadNibNamed("InviteInvestView", owner: nil, options: nil)?.first as! InviteInvestView
    }

}
