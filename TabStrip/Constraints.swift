//
//  EWConstraints.swift
//  HeaderMenu
//
//  Created by peer on 16/8/10.
//  Copyright © 2016年 peer. All rights reserved.
//

import Foundation

class ConstraintsEx{
    
    class func makeEqualWidthConstraints(superView:UIView,
                                         subViews:[UIView],
                                         edgesInsets:UIEdgeInsets,
                                         itemSpacing:CGFloat){
        var preView: UIView?
        
        for (idx, view) in subViews.enumerate(){
            view.snp_makeConstraints(closure: { (make) in
                if idx == 0 {
                    make.leading.equalTo(superView.snp_leading).offset(edgesInsets.left).priority(999)
                } else if idx == subViews.count-1 {
                    make.trailing.equalTo(superView.snp_trailing).offset(-edgesInsets.right).priority(UILayoutPriorityRequired)
                }
                
                /*
                make.top.equalTo(superView.snp_top).offset(edgesInsets.top)
                make.bottom.equalTo(superView.snp_bottom).offset(-edgesInsets.bottom)
                */
                make.centerY.equalTo(superView)
 
                if let preView = preView {
                    make.leading.equalTo(preView.snp_trailing).offset(itemSpacing).priority(999)
                    make.width.equalTo(preView.snp_width)
                }
            })
            preView = view
        }
    }
    
    class func makeFlowConstraints(superView:UIView, subViews:[UIView], edgesInsets:UIEdgeInsets, spacing: CGFloat){
        
        var lastView: UIView?
        
        for (idx, view) in subViews.enumerate(){
            view.snp_makeConstraints(closure: { (make) in
                if let lastView = lastView {
                    make.leading.equalTo(lastView.snp_trailing).offset(spacing).priority(999)
                }else {
                    make.leading.equalTo(superView.snp_leading).offset(edgesInsets.left)
                }
                
                make.centerY.equalTo(superView)
                
                if idx == subViews.count-1 {
                    make.trailing.equalTo(superView).offset(-edgesInsets.right)
                }
            })
            
            lastView = view
        }
        
    }
    
}