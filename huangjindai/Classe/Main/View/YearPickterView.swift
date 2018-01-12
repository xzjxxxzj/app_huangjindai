//
//  YearPickterView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/28.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit

protocol YearPickterViewDelegate : class {
    func selectClick(_ value:String)
}

class YearPickterView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    fileprivate let pickerView:UIPickerView = UIPickerView()
    fileprivate let selectView:UIView = UIView()
    
    fileprivate var data : [String] = []
    fileprivate var selectYear : Int = 0
    
    weak var delegate : YearPickterViewDelegate?
    
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
    
    init(frame: CGRect, min: Int, max:Int,select:Int)
    {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        for year in min...max {
            data.append("\(year)")
        }
        selectYear = select - min
        loadView()
    }
    
    fileprivate func loadView()
    {
        addSubview(selectView)
        selectView.frame = bounds
        selectView.addSubview(selectBtnView)
        selectView.addSubview(pickerView)
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = UIColor(r: 244, g: 244, b: 244)
        pickerView.frame = CGRect(x: 0, y: 50, width: kMobileW, height: bounds.height - 50)
        pickerView.selectRow(selectYear, inComponent: 0, animated: true)
        
        pickerView.reloadAllComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //设置列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //设置行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    //设置选择框内容
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = data[row]
        label.textColor = UIColor(r: 152, g: 213, b: 93)
        label.font = UIFont.systemFont(ofSize: 25)
        label.textAlignment = NSTextAlignment.center
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
        let stringData = data[row]
        delegate?.selectClick(stringData)
        removeFromSuperview()
    }
    
    func close()
    {
        removeFromSuperview()
    }
}
