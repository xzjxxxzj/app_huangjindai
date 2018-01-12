//
//  Badg.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

fileprivate let lxfFlag: Int = 666

class Badg : UIView {
    // MARK:- 显示小红点
    func showBadgOn(index itemIndex: Int, tabbarItemNums: CGFloat = 4.0) -> UILabel {
        // 移除之前的小红点
        self.removeBadgeOn(index: itemIndex)
        
        let tabFrame = self.frame
        // 创建数字
        let label = UILabel()
        label.tag = itemIndex + lxfFlag
        label.text = "99"
        label.font = UIFont.systemFont(ofSize: 9)
        label.font = UIFont.boldSystemFont(ofSize: 8)
        label.layer.cornerRadius = 7
        label.layer.masksToBounds = true
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.red
        // 确定小红点的位置
        let percentX: CGFloat = (CGFloat(itemIndex) + 0.59) / tabbarItemNums
        let x: CGFloat = CGFloat(ceilf(Float(percentX * tabFrame.size.width)))
        let y: CGFloat = CGFloat(ceilf(Float(0.115 * tabFrame.size.height)))
        label.frame = CGRect(x: x, y: y, width: 14, height: 14)
        return label
    }
    
    // MARK:- 隐藏小红点
    func hideBadg(on itemIndex: Int) {
        // 移除小红点
        self.removeBadgeOn(index: itemIndex)
    }
    
    // MARK:- 移除小红点
    fileprivate func removeBadgeOn(index itemIndex: Int) {
        // 按照tag值进行移除
        _ = subviews.map {
            if $0.tag == itemIndex + lxfFlag {
                
                $0.removeFromSuperview()
            }
        }
    }
}
