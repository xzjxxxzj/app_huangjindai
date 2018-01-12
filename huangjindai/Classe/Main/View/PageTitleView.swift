//
//  PageTitleView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/11/2.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
//设置是否可以拉动
private var isCanScroll = false

protocol PageTitleViewDelegate : class {
    func pageTitleView(_ titleView : PageTitleView, selectedIndex index : Int)
}

class PageTitleView: UIView {
    //保存label文字组
    fileprivate var titles : [String]
    //下划线高度
    fileprivate let kScrollLineH : CGFloat = 2
    fileprivate let kNormalColor : (CGFloat, CGFloat, CGFloat) = (85, 85, 85)
    fileprivate let kSelectColor : (CGFloat, CGFloat, CGFloat) = (255, 128, 0)
    //保存之前的label tag值
    fileprivate var oldLabelTag = 0
    
    weak var delegate : PageTitleViewDelegate?
    
    init(frame: CGRect, titles : [String], isScroll : Bool = false) {
        isCanScroll = isScroll
        self.titles = titles
        super.init(frame: frame)
        setupUI()
    }
    fileprivate lazy var labels : [UILabel] = [UILabel]()
    
    fileprivate lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.backgroundColor = UIColor.white
        if !isCanScroll {
            scrollView.isScrollEnabled = false
        }
        return scrollView
    }()
    
    fileprivate lazy var scrollLine : UIView = {
        let scrollLine = UIView()
        scrollLine.backgroundColor = UIColor.orange
        return scrollLine
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageTitleView {
    
    fileprivate func setupUI() {
        //添加scrollView
        addSubview(scrollView)
        scrollView.frame = bounds
        //添加titles
        setupLables()
        //添加滑块和底线
        setupLine()
    }
    
    fileprivate func setupLables() {
        
        let labelW : CGFloat = frame.width / CGFloat(titles.count)
        let labelH : CGFloat = frame.height - kScrollLineH
        let labelY : CGFloat = scrollView.frame.origin.y
        if isCanScroll && titles.count > 4 {
            scrollView.frame = CGRect(x: 0,y: 0,width: kMobileW,height: frame.height)
            scrollView.contentSize = CGSize(width: frame.width, height: 0)
        }
        for (index, title) in titles.enumerated() {
            let label = UILabel()
            label.text = title
            label.tag = index
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor.darkGray
            label.textAlignment = .center
            let labelX : CGFloat = labelW * CGFloat(index)
            label.frame = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)
            labels.append(label)
            //添加lable到scrollView中
            addSubview(label)
            //如果不是最后一个则在中间添加一条竖线
            if index != (titles.count - 1)
            {
                let lineView = UIView()
                lineView.backgroundColor = UIColor(r: 204, g: 204, b: 204)
                lineView.frame = CGRect(x: labelW , y: labelH/3, width: 2, height: labelH/3)
                label.addSubview(lineView)
            }
            //开启lable交互
            label.isUserInteractionEnabled = true
            let labelClick = UITapGestureRecognizer(target: self, action: #selector(self.labelClick(_:)))
            label.addGestureRecognizer(labelClick)
        }
    }
    
    fileprivate func setupLine()
    {
        //创建底部横线
//        let lineH : CGFloat = 0.5
//        let btnLine = UIView()
//        btnLine.backgroundColor = UIColor.lightGray
//        btnLine.frame = CGRect(x: 0, y: frame.height - lineH, width: frame.width, height: lineH)
//        addSubview(btnLine)
        
        //创建下划线
        //获取第一个label
        guard let firstLabel = labels.first else { return }
        firstLabel.textColor = UIColor.orange
        
        addSubview(scrollLine)
        scrollLine.frame = CGRect(x: firstLabel.frame.origin.x, y: frame.height - kScrollLineH, width: firstLabel.frame.width, height: kScrollLineH)
    }
}

//监听label点击时间
extension PageTitleView {
    @objc fileprivate func labelClick(_ tapGest : UITapGestureRecognizer) {
        //获取当前label
        guard let currentLabel = tapGest.view as? UILabel else {return}
        //如果重复点击同一个label 则直接返回
        if currentLabel.tag == oldLabelTag {return}
        //获取之前label
        let oldLable = labels[oldLabelTag]
        //保存新的label tag值
        oldLabelTag = currentLabel.tag
        
        //移动label
        if isCanScroll && labels.count > 4{
            //左边一个labelTag
            let leftTag = oldLabelTag - 1
            //右边第二个labelTag
            let endTag = oldLabelTag + 2
            var viewX : CGFloat = 0
            if leftTag > 0 && endTag <= labels.count - 2 {
                viewX = currentLabel.frame.width * CGFloat(leftTag)
            } else if leftTag > 0 && endTag >= labels.count - 3 {
                viewX = currentLabel.frame.width * CGFloat(labels.count - 4)
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.scrollView.setContentOffset(CGPoint(x: viewX, y: 0), animated: false)
            })
        }
        //修改之前lable颜色值
        oldLable.textColor = UIColor.darkGray
        //修改新lable的颜色值
        currentLabel.textColor = UIColor.orange
        
        //修改黄色下标位置
        let scrollLineX = CGFloat(oldLabelTag) * scrollLine.frame.width
        //添加动画效果
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollLine.frame.origin.x = scrollLineX
        })
        // 6.通知代理
        delegate?.pageTitleView(self, selectedIndex: oldLabelTag)
    }
}

extension PageTitleView {
    func setTitleWithProgress(_ progress: CGFloat, sourceIndex : Int, targetIndex : Int) {
        //获取开始的label 和结束的label
        let sourceLabel = labels[sourceIndex]
        let targetLabel = labels[targetIndex]
        //移动label
        if isCanScroll && sourceIndex == targetIndex && labels.count > 4{
            //左边一个labelTag
            let leftTag = oldLabelTag - 1
            //右边第二个labelTag
            let endTag = oldLabelTag + 2
            var viewX : CGFloat = 0
            if leftTag > 0 && endTag <= labels.count - 2 {
                viewX = sourceLabel.frame.width * CGFloat(leftTag)
            } else if leftTag > 0 && endTag >= labels.count - 3 {
                viewX = sourceLabel.frame.width * CGFloat(labels.count - 4)
            }
            UIView.animate(withDuration: 0.5, animations: {
                self.scrollView.setContentOffset(CGPoint(x: viewX, y: 0), animated: false)
            })
        }
        //相距长度
        let moveTotalX = targetLabel.frame.origin.x - sourceLabel.frame.origin.x
        let moveX = moveTotalX * progress
        UIView.animate(withDuration: 0.5, animations: {
            self.scrollLine.frame.origin.x = sourceLabel.frame.origin.x + moveX
        })
        
        let colorDelta = (kSelectColor.0 - kNormalColor.0, kSelectColor.1 - kNormalColor.1, kSelectColor.2 - kNormalColor.2)
        
        // 3.2.变化sourceLabel
        sourceLabel.textColor = UIColor(r: kSelectColor.0 - colorDelta.0 * progress, g: kSelectColor.1 - colorDelta.1 * progress, b: kSelectColor.2 - colorDelta.2 * progress)
        
        // 3.2.变化targetLabel
        targetLabel.textColor = UIColor(r: kNormalColor.0 + colorDelta.0 * progress, g: kNormalColor.1 + colorDelta.1 * progress, b: kNormalColor.2 + colorDelta.2 * progress)
        
        // 4.记录最新的index
        oldLabelTag = targetIndex
    }
}
