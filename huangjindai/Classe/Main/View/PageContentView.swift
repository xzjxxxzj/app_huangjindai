//
//  PageContentView.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/20.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
protocol PageContentViewDelegate : class {
    func pageContentView(_ contentView : PageContentView, progress : CGFloat, sourceIndex : Int, targetIndex : Int)
}

private let ContentCellID = "ContentCellID"

class PageContentView : UIView {
    
    //定义控制器属性
    //1 定义子控制器属性
    fileprivate var childVcs : [UIViewController]
    fileprivate weak var parentVc : UIViewController?
    fileprivate var isForbidScrollDelegate : Bool = false
    //定义视图初始X轴位置
    fileprivate var startX : CGFloat = 0
    weak var delegate : PageContentViewDelegate?
    
    fileprivate lazy var contentionView : UICollectionView = {[weak self] in
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = (self?.bounds.size)!
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let contentionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        contentionView.showsHorizontalScrollIndicator = false
        contentionView.isPagingEnabled = true
        contentionView.bounces = false
        contentionView.dataSource = self
        contentionView.delegate = self
        contentionView.scrollsToTop = false
        contentionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ContentCellID)
        return contentionView
    }()
    
    init(frame: CGRect, childVcs : [UIViewController], parentVc : UIViewController?) {
        self.childVcs = childVcs
        self.parentVc = parentVc
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//设置UIcontent布局
extension PageContentView {
    fileprivate func setupUI(){
        //将所有子控制器加入UI
        for childVc in childVcs {
            parentVc?.addChildViewController(childVc)
        }
        addSubview(contentionView)
        contentionView.frame = bounds
    }
    
    func setScrollEnable (isEnable : Bool = true) {
        contentionView.isScrollEnabled = isEnable
    }
}

extension PageContentView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return childVcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.创建Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCellID, for: indexPath)
        
        // 2.给Cell设置内容
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let childVc = childVcs[(indexPath as NSIndexPath).item]
        childVc.view.frame = cell.contentView.bounds
        cell.contentView.addSubview(childVc.view)
        
        return cell
    }
}

extension PageContentView : UICollectionViewDelegate {
    //获取初始宽度
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isForbidScrollDelegate = false
        startX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isForbidScrollDelegate { return }
        //拉动百分比
        var progress : CGFloat = 0
        //
        var sourceIndex : Int = 0
        var targetIndex : Int = 0
        let currentOffsetX = scrollView.contentOffset.x
        let scrollViewW = scrollView.bounds.width
        if currentOffsetX > startX {
            progress = currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW)
            sourceIndex = Int(currentOffsetX / scrollViewW)
            
            targetIndex = sourceIndex + 1
            if targetIndex >= childVcs.count {
                targetIndex = childVcs.count - 1
            }
            //完全划过去
            if currentOffsetX - startX == scrollViewW {
                progress = 1
                targetIndex = sourceIndex
            }
        } else {
            progress = 1 - (currentOffsetX / scrollViewW - floor(currentOffsetX / scrollViewW))
            
            targetIndex = Int(currentOffsetX / scrollViewW)
            
            sourceIndex = targetIndex + 1
            if sourceIndex >= childVcs.count {
                sourceIndex = childVcs.count - 1
            }
            
            //完全划过去
            if startX - currentOffsetX == scrollViewW {
                sourceIndex = targetIndex
            }
        }
        
        delegate?.pageContentView(self, progress: progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
}

extension PageContentView {
    func setCurrentIndex(_ currentIndex : Int) {
        isForbidScrollDelegate = true
        
        let offsetX = CGFloat(currentIndex) * contentionView.frame.width
        contentionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}
