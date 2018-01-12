//
//  UIStartImage.swift
//  swich
//
//  Created by Zhenjie Xu on 2017/9/24.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import SnapKit


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
        self.button?.setTitle("进入GuideVC", for: .normal)
        self.button?.backgroundColor = UIColor.clear
        self.button?.setTitleColor(UIColor.blue, for: .normal)
        self.button?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        self.button?.layer.masksToBounds = true
        self.button?.layer.borderColor = UIColor.black.cgColor
        self.button?.layer.borderWidth = 1.0
        self.button?.layer.cornerRadius = 5.0
        
        
        self.button?.snp.makeConstraints({ (make) in
            
            make.centerX.equalTo(self.contentView)
            make.width.equalTo(100)
            make.height.equalTo(30)
            make.bottom.equalTo(self.contentView.snp.bottom).offset(-70)
            
        })
        
    }
    
}



class StartVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    var delegate:StartVcDelegat?
    
    var window:UIWindow?
    var collectionView:UICollectionView?
    var pageControl:UIPageControl?
    var images:NSArray?
    
    
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
        collectionView?.bounces = false
        collectionView?.isPagingEnabled = true
        collectionView?.register(StartViewCell.self ,forCellWithReuseIdentifier:"cell")
        
        self.view.addSubview(collectionView!)
        self.collectionView?.snp.makeConstraints { (make) in
            
            make.edges.equalTo(self.view)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


// MARK:// CollectionViewDelegate
extension StartVC{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.images?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as?StartViewCell
        
        let imageName:String = (self.images![indexPath.item]as?String)!
        
        cell?.imageView?.image = UIImage(named:imageName)
        if indexPath.item == (self.images?.count)!-1{
            
            cell?.button?.isHidden = false
            cell?.button?.addTarget(self, action: #selector(self.nextButtonHandel), for: .touchUpInside)
            
        }else{
            
            cell?.button?.isHidden = true
        }
        
        return cell!
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        self.pageControl?.currentPage = Int(scrollView.contentOffset.x/kMobileW)
    }
}

extension StartVC{
    
    func nextButtonHandel(){
        
        delegate?.jumpMainVC()
    }
    
    func setGuideImages(images:NSArray){
        
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

