//
//  WKWebViewController.swift
//  huangjindai
//
//  Created by Zhenjie Xu on 2017/10/20.
//  Copyright © 2017年 Zhenjie Xu. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController,WKUIDelegate,WKNavigationDelegate
{
    var urlString:String?
    
    private var leftBarButton:UIBarButtonItem?
    private var leftBarButtonSecond:UIBarButtonItem?
    private var negativeSpacer:UIBarButtonItem?
    
    private var isCanBack = true
    /*
     *加载WKWebView对象
     */
    lazy var wkWebview:WKWebView =
        {
            () -> WKWebView in
            var tempWebView = WKWebView.init(frame: self.view.bounds)
            tempWebView.uiDelegate = self
            tempWebView.navigationDelegate = self
            tempWebView.backgroundColor = UIColor.white
            tempWebView.autoresizingMask = UIViewAutoresizing.init(rawValue: 1|4)
            tempWebView.isMultipleTouchEnabled = true
            tempWebView.autoresizesSubviews = true
            tempWebView.scrollView.alwaysBounceVertical = true
            tempWebView.allowsBackForwardNavigationGestures = true
            return tempWebView
    }()
    
    
    /*
     *懒加载UIProgressView进度条对象
     */
    lazy var progress:UIProgressView =
        {
            () -> UIProgressView in
            var rect:CGRect = CGRect.init(x: 0, y: 0, width: kMobileW, height: 2.0)
            let tempProgressView = UIProgressView.init(frame: rect)
            tempProgressView.tintColor = UIColor.red
            tempProgressView.backgroundColor = UIColor.gray
            return tempProgressView
    }()
    
    /*
     *创建BarButtonItem
     */
    
    func setupBarButtonItem()
    {
        self.leftBarButton = UIBarButtonItem.init(image: UIImage.init(named: "backItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(WKWebViewController.selectedToBack))
        self.leftBarButtonSecond = UIBarButtonItem.init(image: UIImage.init(named: "closeItemImage"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(WKWebViewController.selectedToClose))
        self.leftBarButtonSecond?.imageInsets = UIEdgeInsetsMake(0, -20, 0, 20)
        
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        
        //添加刷新按钮
        let item = UIBarButtonItem.init(title: "刷新", style: UIBarButtonItemStyle.plain, target: self, action: #selector(WKWebViewController.rightItemClick))
        //占位控件
        navigationItem.rightBarButtonItem = item
    }
    
    //刷新页面
    @objc func rightItemClick()
    {
        self.wkWebview.reload()
    }
    
    //执行JS方法
    func runJs(funName jsStr : String)
    {
        self.wkWebview.evaluateJavaScript(jsStr)
    }
    
    /*
     *设置UI部分
     */
    func setupUI()
    {
        automaticallyAdjustsScrollViewInsets = false
        self.setupBarButtonItem()
        self.view.backgroundColor = UIColor.white
        let contentView = UIView(frame : CGRect(x: 0, y: kStatusH + kHeardH - kHotH, width: kMobileW, height: kMobileH - kStatusH - kHeardH + kHotH))
        self.view.addSubview(contentView)
        contentView.addSubview(self.wkWebview)
        contentView.addSubview(self.progress)
    }
    
    /*
     *加载网页 request
     */
    func loadRequest()
    {
        self.wkWebview.load(NSURLRequest.init(url: NSURL.init(string: self.urlString!)! as URL) as URLRequest)
    }
    
    /*
     *添加观察者
     *作用：监听 加载进度值estimatedProgress、是否可以返回上一网页canGoBack、页面title
     */
    func addKVOObserver()
    {
        self.wkWebview.addObserver(self, forKeyPath: "estimatedProgress", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "canGoBack", options:[NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
        self.wkWebview.addObserver(self, forKeyPath: "title", options: [NSKeyValueObservingOptions.new,NSKeyValueObservingOptions.old], context: nil)
    }
    
    /*
     *移除观察者,类似OC中的dealloc
     *观察者的创建和移除一定要成对出现
     */
    deinit
    {
        self.wkWebview.removeObserver(self, forKeyPath: "estimatedProgress")
        self.wkWebview.removeObserver(self, forKeyPath: "canGoBack")
        self.wkWebview.removeObserver(self, forKeyPath: "title")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setupUI()
        self.loadRequest()
        self.addKVOObserver()
    }
    
    /*
     *返回按钮执行事件
     */
    @objc func selectedToBack()
    {
        if (self.wkWebview.canGoBack == true && isCanBack)
        {
            self.wkWebview.goBack()
        }
        else
        {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    /*
     *关闭按钮执行事件
     */
    @objc func selectedToClose()
    {
        self.navigationController?.popViewController(animated: false)
    }
    
    
    /*
     *观察者的监听方法
     */
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "estimatedProgress"
        {
            self.progress.alpha = 1.0
            self.progress .setProgress(Float(self.wkWebview.estimatedProgress), animated: true)
            if self.wkWebview.estimatedProgress >= 1
            {
                UIView.animate(withDuration: 1.0, animations: {
                    self.progress.alpha = 0
                }, completion: { (finished) in
                    self.progress .setProgress(0.0, animated: false)
                })
            }
        }
        else if keyPath == "title"
        {
            self.navigationItem.title = self.wkWebview.title
        }
        else if keyPath == "canGoBack"
        {
            if self.wkWebview.canGoBack == true && isCanBack
            {
                let items = [self.leftBarButton,self.leftBarButtonSecond]
                self.navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
            }
            else
            {
                self.navigationItem.leftBarButtonItem = self.leftBarButton
            }
        }
        else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public func setIsCanBack(_ type : Bool)
    {
        isCanBack = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let path = navigationAction.request.url?.lastPathComponent
        let ToApp: [String: String] = ["Invest":"","Login":"","Invite":""]
        if path!.count > 0 && ToApp[path!] != nil {
            if path! == "Invest" {
                let vc = MainViewController()
                tabIndex = 1
                self.navigationController?.present(vc, animated: true, completion: nil)
            }
            if path! == "Login" {
                let vc = LoginViewController()
                vc.setLastView(toView: HomeViewController(), IsbackHome: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if path! == "Invite" {
                if UserDefaults.standard.dictionary(forKey: "user") == nil {
                    let loginViewController = LoginViewController()
                    loginViewController.loginToHome()
                    self.navigationController!.pushViewController(loginViewController, animated: true)
                }else {
                    let vc = UserInviteViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            decisionHandler(WKNavigationActionPolicy.cancel)
        }else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
