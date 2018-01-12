//
//  zekouSelectView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/12/6.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

protocol ZekouSelectViewDelegate : class {
    func numSelectClick(_ value:String)
}

class ZekouSelectView : UIView, UIPickerViewDelegate, UIPickerViewDataSource {

    fileprivate let pickerView:UIPickerView = UIPickerView()
    fileprivate let selectView:UIView = UIView()
    
    fileprivate var num : [String] = []
    fileprivate var floatNum : [String] = []
    
    weak var delegate : ZekouSelectViewDelegate?
    
    fileprivate lazy var selectBtnView : UIView = {
        let btnView = UIView(frame: CGRect(x: 0, y: 0, width: kMobileW, height: 50))
        btnView.backgroundColor = UIColor.white
        let closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: kMobileW/2, height: 50))
        closeBtn.backgroundColor = UIColor(r: 217, g: 96, b: 86)
        closeBtn.setTitle("取消", for: .normal)
        closeBtn.titleLabel?.textColor = UIColor.white
        closeBtn.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btnView.addSubview(closeBtn)
        let selectBtn = UIButton(frame: CGRect(x: kMobileW/2, y: 0, width: kMobileW/2, height: 50))
        selectBtn.backgroundColor = UIColor(r: 152, g: 213, b: 93)
        selectBtn.setTitle("确定", for: .normal)
        selectBtn.addTarget(self, action: #selector(successClick), for: .touchUpInside)
        selectBtn.titleLabel?.textColor = UIColor.white
        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btnView.addSubview(selectBtn)
        return btnView
    }()
    
    init(frame: CGRect,_ select:Double)
    {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        for index in 0...10 {
            var numString = "\(100 - index)"
            if (100 - index) < 100 {
                numString = "0\(numString)"
            }
            num.append(numString)
        }
        floatNum.append("000")
        for index1 in 1...100 {
            var floatString = "\(100 - index1)"
            if (100 - index1) < 100 && (100 - index1) >= 10 {
                floatString = "0\(floatString)"
            }else if (100 - index1) < 10 {
                floatString = "00\(100 - index1)"
            }
            floatNum.append(floatString)
        }
        loadView()
    }
    
    fileprivate func loadView()
    {
        addSubview(selectView)
        selectView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        selectView.frame = bounds
        selectView.addSubview(selectBtnView)
        selectView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        pickerView.frame = CGRect(x: kMobileW/4, y: 50, width: kMobileW/2, height: bounds.height - 50)
        pickerView.selectRow(0, inComponent: 0, animated: true)
        pickerView.selectRow(0, inComponent: 1, animated: true)
        pickerView.reloadAllComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    //设置行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 11
        }else if component == 1 {
            return 1
        }else {
            return 101
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 1 {
            return CGFloat(10)
        }
        return CGFloat(40)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let row1 = pickerView.selectedRow(inComponent: 0)
        let row2 = pickerView.selectedRow(inComponent: 2)
        if row2 != 0 && row1 == 0 {
            pickerView.selectRow(1, inComponent: 0, animated: true)
        }
    }
    
    //设置选择框内容
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        if component == 0 {
            label.text = "\(num[row])"
            label.textAlignment = NSTextAlignment.right
            label.textColor = UIColor(r: 152, g: 213, b: 93)
            label.font = UIFont.systemFont(ofSize: 20)
        }else if component == 1 {
            label.text = "."
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.black
            label.font = UIFont.systemFont(ofSize: 30)
        }else {
            label.text = "\(floatNum[row])"
            label.textAlignment = NSTextAlignment.left
            label.textColor = UIColor(r: 152, g: 213, b: 93)
            label.font = UIFont.systemFont(ofSize: 20)
        }
        return label
    }
    
    @objc fileprivate func closeClick()
    {
        removeFromSuperview()
    }
    
    @objc fileprivate func successClick()
    {
        //获取选中的值
        let row = pickerView.selectedRow(inComponent: 0)
        let zhenshu : Int = Int(num[row])!
        let row1 = pickerView.selectedRow(inComponent: 2)
        let xiaoshu : Int = Int(floatNum[row1])!
        delegate?.numSelectClick("\(zhenshu).\(xiaoshu)")
        removeFromSuperview()
    }
    
    func close()
    {
        removeFromSuperview()
    }

}
