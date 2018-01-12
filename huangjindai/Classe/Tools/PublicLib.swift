//
//  PublicLib.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/23.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//
import UIKit

class PublicLib {
    //设置字体多种颜色和大小
    class func setStringColer(string : String, setString: String, color: UIColor, size : UIFont) -> NSMutableAttributedString{
        let attrstring:NSMutableAttributedString = NSMutableAttributedString(string:string)
        let str = NSString(string: string)
        let theRange = str.range(of: setString)
        attrstring.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: theRange)
        attrstring.addAttribute(NSAttributedStringKey.font, value: size, range: theRange)
        return attrstring
    }
    
    //根据字体大小计算字符串的宽
    class func countStringFrame(string : String, font : UIFont) -> CGRect {
        let attributes = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect : CGRect = string.boundingRect(with: CGSize(),options: option,attributes: attributes as? [NSAttributedStringKey : Any],context: nil)
        return rect
    }
    
    //根据字体大小及宽度计算高度
    
    class func countStringHeigh(string : String, font : UIFont, width : CGFloat) -> CGFloat{
        let normalText : NSString = NSString(string: string)
        let size = CGSize(width: width, height: 1000)
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let stringSize = normalText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : Any], context: nil).size
        return stringSize.height
    }
    
    //字符串替换
    class func subString(string : String, start : Int, lenth : Int, replay : String = "***") -> String {
        let len = string.count
        var subLenth = lenth
        if lenth < 0 {
            subLenth = len + lenth - start
        }
        if len <= lenth || len <= (start + 1) {
            return string
        }
        let st = string.index(string.startIndex, offsetBy: start)
        let startSt = string[...st]
        let end = string.index(string.startIndex, offsetBy: start+subLenth)
        let endSt = string[end...]
        return "\(startSt)\(replay)\(endSt)"
    }
    
    //绘制二维码
    class func createQRForString(qrString: String?, qrImageName: String?) -> UIImage?{
        if let sureQRString = qrString{
            let stringData = sureQRString.data(using: String.Encoding.utf8, allowLossyConversion: false)
            //创建一个二维码的滤镜
            let qrFilter = CIFilter(name: "CIQRCodeGenerator")
            qrFilter?.setValue(stringData, forKey: "inputMessage")
            qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
            let qrCIImage = qrFilter?.outputImage
            
            // 创建一个颜色滤镜,黑白色
            let colorFilter = CIFilter(name: "CIFalseColor")!
            colorFilter.setDefaults()
            colorFilter.setValue(qrCIImage, forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
            colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
            // 返回二维码image
            let codeImage = UIImage(ciImage: (colorFilter.outputImage!.transformed(by: CGAffineTransform(scaleX: 5, y: 5))))
            
            // 中间一般放logo
            if let iconImage = UIImage(named: qrImageName!) {
                let rect = CGRect(x: 0, y: 0, width: codeImage.size.width, height: codeImage.size.height)
                
                UIGraphicsBeginImageContext(rect.size)
                codeImage.draw(in: rect)
                let avatarSize = CGSize(width: rect.size.width*0.25, height: rect.size.height*0.25)
                
                let x = (rect.width - avatarSize.width) * 0.5
                let y = (rect.height - avatarSize.height) * 0.5
                iconImage.draw(in: CGRect(x: x, y: y, width: avatarSize.width, height: avatarSize.height))
                
                let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                return resultImage
            }
            return codeImage
        }
        return nil
    }
}
