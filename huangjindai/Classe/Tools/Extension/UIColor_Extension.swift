//
//  UIColor_Extension.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r : CGFloat, g : CGFloat, b : CGFloat, alpha : CGFloat = 1.0) {
        self.init(red : r/255.0, green : g/255.0, blue : b/255.0, alpha : alpha)
    }
    
    //MARK:转化为颜色值
    static func colorWith(hexString:String, alpha:Float) -> UIColor
    {
        var cString:String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        //TODO:做一些容错处理
        if cString.count < 6{ return UIColor.clear }
        if cString.hasPrefix("0X")
        {
            let start = cString.index(cString.startIndex, offsetBy: 2)
            cString = String(cString[start...])
            
        }
        
        if cString.hasPrefix("#")
        {
            let start = cString.index(cString.startIndex, offsetBy: 1)
            cString = String(cString[start...])
        }
        if cString.count != 6{ return UIColor.clear }
        
        
        //TODO:R
        let start_r = cString.index(cString.startIndex, offsetBy: 0)
        let end_r = cString.index(cString.endIndex, offsetBy: -4)
        let range_r = Range.init(uncheckedBounds: (lower: start_r, upper: end_r))
        let string_r:String = String(cString[range_r])
        
        //TODO:G
        let start_g = cString.index(cString.startIndex, offsetBy: 2)
        let end_g = cString.index(cString.endIndex, offsetBy: -2)
        let range_g = Range.init(uncheckedBounds: (lower: start_g, upper: end_g))
        let string_g:String = String(cString[range_g])
        
        //TODO:B
        let start_b = cString.index(cString.startIndex, offsetBy: 4)
        let end_b = cString.index(cString.endIndex, offsetBy: 0)
        let range_b = Range.init(uncheckedBounds: (lower: start_b, upper: end_b))
        let string_b:String = String(cString[range_b])
        
        return UIColor(r: CGFloat(self.hexTodec(number:string_r)),
                            g: CGFloat(self.hexTodec(number: string_g)),
                            b: CGFloat(self.hexTodec(number: string_b)))
    }
    
    //MARK:16进制字符串转10进制数字
    static func hexTodec(number num:String) -> Int
    {
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8
        {
            sum = sum * 16 + Int(i) - 48 //0-9,从48开始
            if i >= 65
            { //A-Z,从65开始,但有初始值10,所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
}
