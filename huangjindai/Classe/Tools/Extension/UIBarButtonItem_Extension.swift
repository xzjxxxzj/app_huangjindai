//
//  UIBarButtonItem_Extension.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/19.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    convenience init(imageName : String, target : AnyObject, action : Selector, highImageName : String = "", size : CGSize = CGSize.zero)  {
        // 1.创建UIButton
        let btn = UIButton(type: .custom)
        
        // 2.设置btn的图片
        btn.setImage(UIImage(named: imageName), for: .normal)
        if highImageName != "" {
            btn.setImage(UIImage(named: highImageName), for: .highlighted)
        }
        
        // 3.设置btn的尺寸
        if size == CGSize.zero {
            btn.sizeToFit()
        } else {
            btn.frame = CGRect(origin: CGPoint.zero, size: size)
        }
        
        btn.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        
        // 4.创建UIBarButtonItem
        self.init(customView : btn)
    }
}

