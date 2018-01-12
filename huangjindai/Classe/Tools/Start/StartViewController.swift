//
//  StartViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/18.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

//添加定时器
fileprivate var timer : Timer? = nil
/** 间隔时间 */
fileprivate var timeInterval : CGFloat = 3.0
/** 当前显示的图片在数组中的下标 */
fileprivate var cycleIndex : NSInteger = 0
// 显示图片是本地路径还是网络路径
fileprivate var isNetWorks : Bool = true

protocol StartVcDelegat : NSObjectProtocol{
    
    func jumpMainVC()->Void
}

class StartViewCell: UICollectionViewCell {
    
    var imageView:UIImageView?
    var  button:UIButton?
    override init(frame:CGRect){
        
        super.init(frame: frame)
        self.sutupInitUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sutupInitUI(){
        
        self.layer.masksToBounds = true
        self.imageView = UIImageView()
        self.imageView?.contentMode = .scaleAspectFill
        self.button = UIButton()
        
        self.contentView.addSubview(self.imageView!)
        self.imageView?.snp.makeConstraints({ (make) in
            make.edges.equalTo(self.contentView)
            make.centerX.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        })
        
        self.contentView.addSubview(self.button!)
        
        self.button?.isHidden = true
        //按钮文字，默认没文字
        self.button?.setTitle("", for: .normal)
        self.button?.backgroundColor = UIColor.clear
        self.button?.setTitleColor(UIColor.blue, for: .normal)
        self.button?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        self.button?.layer.masksToBounds = true
        //按钮边框
        //self.button?.layer.borderColor = UIColor.black.cgColor
        //self.button?.layer.borderWidth = 1.0
        //self.button?.layer.cornerRadius = 5.0
        
        
        self.button?.snp.makeConstraints({ (make) in
            //按钮位置
            make.centerX.equalTo(self.contentView)
            make.width.equalTo(155)
            make.height.equalTo(65)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-65)
            
        })
        
    }
    
}



class StartVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    var delegate:StartVcDelegat?
    
    var window:UIWindow?
    var collectionView:UICollectionView?
    var pageControl:UIPageControl?
    var images:[String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupControl()
        // Do any additional setup after loading the view.
    }
    
    func setupControl(){
        
        let screen = UIScreen.main.bounds
        let layout:UICollectionViewFlowLayout  = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing  = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = screen.size
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        
        collectionView?.backgroundColor = UIColor.black
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
        collectionView?.register(StartViewCell.self ,forCellWithReuseIdentifier:"cell")
        
        self.view.addSubview(collectionView!)
        self.collectionView?.snp.makeConstraints { (make) in
            
            make.edges.equalTo(self.view)
        }
        
        creatTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     *  创建定时器
     */
    fileprivate func creatTimer() -> Void {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval), target: self, selector: #selector(timeAction), userInfo: nil, repeats: true)
    }
    
    /**
     *  定时器暂停
     */
    func timeStop() -> Void {
        if (timer != nil) {
            timer?.fireDate = Date.distantFuture
        }
    }
    /**
     *  定时器开始
     */
    func timeStart() -> Void {
        if (timer != nil) {
            timer?.fireDate = NSDate(timeIntervalSinceNow: TimeInterval(timeInterval)) as Date
        }
    }
    
    @objc func timeAction() {
        let imageNum = self.images?.count ?? 0
        if cycleIndex == imageNum - 1{
            timeStop()
            nextButtonHandel()
        } else {
            cycleIndex = cycleIndex + 1
            self.pageControl?.currentPage = cycleIndex
            collectionView?.setContentOffset(CGPoint(x:kMobileW * CGFloat(cycleIndex), y:0), animated: true)
        }
    }
}


// MARK:// CollectionViewDelegate
extension StartVC{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.images?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as?StartViewCell
        let imageName:String = self.images![indexPath.item]
        //根据图片是否是URL进行判断加载
        if !isNetWorks {
            cell?.imageView?.image = UIImage(named:imageName)
        } else {
            cell?.imageView?.kf.setImage(with: URL(string: imageName))
        }
        if indexPath.item == (self.images?.count)!-1{

            cell?.button?.isHidden = false
            cell?.button?.addTarget(self, action: #selector(self.nextButtonHandel), for: .touchUpInside)

        }else{

            cell?.button?.isHidden = true
        }

        return cell!
    }
    
    //用户划动的时候
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let nextIndex = Int(scrollView.contentOffset.x/kMobileW)
        if nextIndex > cycleIndex {
            //向左划
            cycleIndex = cycleIndex + 1
        } else {
            //向右划
            cycleIndex = cycleIndex - 1
        }
        self.pageControl?.currentPage = nextIndex
        timeStart()
    }
    
    //用户开始划动的时候
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timeStop()
    }
}

extension StartVC{
    
    @objc func nextButtonHandel(){
        timeStop()
        delegate?.jumpMainVC()
    }
    
    func setGuideImages(images:[String], isNetWork:Bool = true){
        isNetWorks = isNetWork
        self.images = images
        pageControl = UIPageControl()
        
        self.view.addSubview(pageControl!)
        self.pageControl?.snp.makeConstraints({ (make) in
            
            make.bottom.equalTo(self.view.snp.bottom).offset(-30)
            make.centerX.equalTo(self.view)
            make.height.equalTo(44)
            make.width.equalTo(self.view)
        })
        
        pageControl?.numberOfPages = images.count
        pageControl?.pageIndicatorTintColor = UIColor.black
        pageControl?.currentPageIndicatorTintColor = UIColor.gray
        self.collectionView?.reloadData()
    }
}
