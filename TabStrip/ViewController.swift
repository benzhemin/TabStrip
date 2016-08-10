//
//  ViewController.swift
//  HeaderMenu
//
//  Created by peer on 16/8/9.
//  Copyright © 2016年 peer. All rights reserved.
//

import UIKit

class TabLabel: UILabel {
    
    let scaleFactor: CGFloat = 0.85
    
    let fromColor = UIColor.blackColor()
    let toColor = UIColor.redColor()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    //enlarge intrinsicSize
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        
        return CGSize(width: size.width+5, height: size.height+30)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        textAlignment = .Center
        textColor = fromColor//UIColor.blackColor()
        
        //default show 16
        font = UIFont.systemFontOfSize(17)
        
        self.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor)
    }
    
    func animateFocus(progress: CGFloat) {
        textColor = fromColor.interpolateRGBColorTo(toColor, fraction: progress)
        
        let scale = scaleFactor + (1 - scaleFactor) * progress
        self.transform = CGAffineTransformMakeScale(scale, scale)
    }
}

class ChildViewController : UIViewController, IndicatorInfoProvider{
    
    var itemInfo: IndicatorInfo { get{ return "" }
        set{}}
    
    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo{
        return itemInfo
    }
}

@objc protocol TabStripDelegate {
    func tabStripToIndex(index:Int);
}

class TabBarView : UIScrollView {
    
    struct Tag {
        let baseTag: Int
        
        func tagIndex(tag: Int) -> Int {
            return tag - baseTag
        }
        
        func tagOffset(index: Int) -> Int {
            return baseTag + index
        }
    }
    
    let baseTag:Tag = Tag(baseTag: 100)
    
    var titleList: [String]!
    weak var tabDelegate: TabStripDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
    }
    
    override func didMoveToSuperview() {
        prepareUI()
    }
    
    func prepareUI(){
        let spacing: CGFloat = 5
        
        var labelList : [UILabel] = []
        for (idx, title) in titleList.enumerate() {
            let label = TabLabel()
            label.userInteractionEnabled = true
            label.exclusiveTouch = true
            label.text = title
            label.tag = baseTag.tagOffset(idx)
            self.addSubview(label)
            labelList.append(label)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTitle))
            label.addGestureRecognizer(tapGesture)
            
            self.panGestureRecognizer.requireGestureRecognizerToFail(tapGesture)
        }
        
        ConstraintsEx.makeFlowConstraints(self, subViews: labelList, edgesInsets: UIEdgeInsetsMake(0, 15, 0, 15), spacing: spacing)
    }
    
    func tapTitle(tapGesture: UITapGestureRecognizer){
        let tapLabel = tapGesture.view as! TabLabel
        
        let toIndex = baseTag.tagIndex(tapLabel.tag)
        
        tabDelegate?.tabStripToIndex(toIndex)
    }
    
    func tabStripAnimation(fromIndex:Int, toIndex:Int, progress:CGFloat){
        let fromLabel = self.viewWithTag(baseTag.tagOffset(fromIndex)) as? TabLabel
        let toLabel = self.viewWithTag(baseTag.tagOffset(toIndex)) as? TabLabel
        
        fromLabel?.animateFocus(1-progress)
        toLabel?.animateFocus(progress)
        
        if let toLabel=toLabel  where progress >= 1.0 {
            
            let hw = self.bounds.width/2.0//CGRectGetMidX(self.bounds)
            let toCenterX = toLabel.center.x
            
            if toCenterX >= hw && toCenterX <= (contentSize.width-hw) {
                
                let offsetX = toCenterX - hw
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
                })
            } else {
                let destX: CGFloat = toCenterX<hw ? 0 : (contentSize.width-self.bounds.width)
                self.setContentOffset(CGPoint(x: destX, y:0), animated: true)
            }
        }
    }
}

class ViewController: PagerTabStripViewController, PagerTabStripIsProgressiveDelegate, PagerTabStripDataSource, TabStripDelegate{
    
    var titleList = ["精选", "奥运", "新歌声", "NBA", "电视剧", "电影", "综艺", "VIP影院", "娱乐", "美剧", "动漫", "少儿"]
    
    lazy var tabBgView: UIView! = {
        let v = UIView()//UIView(frame: headerBgRect)
        v.backgroundColor = UIColor.whiteColor()
        return v
    }()
    
    var shouldUpdateBarView: Bool = true
    var tabMenuBar: TabBarView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        delegate = self
        datasource = self
    }
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        delegate = self
        datasource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tabBgView)
        
        let headerBgHeight: CGFloat = 70
        tabBgView.snp_makeConstraints { (make) in
            make.leading.top.trailing.equalTo(self.view)
            make.height.equalTo(headerBgHeight)
        }
        
        tabMenuBar = TabBarView(frame: CGRectZero)
        tabMenuBar.titleList = titleList
        tabMenuBar.backgroundColor = UIColor.whiteColor()
        tabMenuBar.alwaysBounceHorizontal = true
        tabMenuBar.alwaysBounceVertical = false
        tabMenuBar.tabDelegate = self
        
        tabBgView.addSubview(tabMenuBar)
        
        tabMenuBar.snp_makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(tabBgView)
            make.height.equalTo(50)
        }
        
        view.layoutIfNeeded()
        
        var f = containerView.frame
        f.origin.y = headerBgHeight
        f.size = CGSize(width: f.size.width, height: self.view.bounds.height - headerBgHeight)
        containerView.frame = f
    }
    
    func tabStripToIndex(toIndex: Int){
        guard toIndex != currentIndex else { return }
        
        tabMenuBar.tabStripAnimation(currentIndex, toIndex: toIndex, progress: 1.0)
        
        shouldUpdateBarView = false
        self.moveToViewControllerAtIndex(toIndex)
    }
    
    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int){
        
    }
    
    func pagerTabStripViewController(pagerTabStripViewController: PagerTabStripViewController, updateIndicatorFromIndex fromIndex: Int, toIndex: Int, withProgressPercentage progressPercentage: CGFloat, indexWasChanged: Bool){
        
        guard shouldUpdateBarView else { return }
        
        tabMenuBar.tabStripAnimation(fromIndex, toIndex: toIndex, progress: progressPercentage)
    }
    
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController]{
        
        var controllers: [UIViewController] = []
        
        for _ in 0..<titleList.count {
            let vc = ChildViewController()
            vc.view.backgroundColor = UIColor.getRandomColor()
            controllers.append(vc)
        }
        
        return controllers
    }
    
    override func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        
        shouldUpdateBarView = true
        
        (navigationController?.view ?? view).userInteractionEnabled = true
    }
    
}

