//
//  ZSSwiftDefine.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import Foundation
import UIKit

public class ZSSwiftDefine{
    public class func DistanceFromTopGuiden(view:AnyObject?)->CGFloat{
    
    return (view?.frame.origin.y)! + (view?.frame.size.height)!
    }
    public class func DistanceFromLeftGuiden(view:AnyObject)->CGFloat
    {
        return (view.frame.origin.x) + (view.frame.size.width)
        
    }
    public class func ViewOrigin(view:AnyObject?)->CGPoint
    {
        return (view?.frame.origin)!
    }
    public class func ViewSize(view:AnyObject?)->CGSize{
    return (view?.frame.size)!
    }

    
    
    
}
