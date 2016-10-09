//
//  ZSAlbumCatalogCell.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import UIKit
import Foundation
import AssetsLibrary

class ZSAlbumCatalogCell: UITableViewCell
{
    var group:ALAssetsGroup!{
    
        didSet{
        
            self.imageView?.image = UIImage(CGImage: group.posterImage().takeUnretainedValue())
            self.setupGroupTitle()
            
        }
    
    }
    private func setupGroupTitle()
    {
        let groupTitleAttribute:Dictionary! = [NSForegroundColorAttributeName:UIColor.blackColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(17)]
        let numberofAssetsAttribute:Dictionary = [NSForegroundColorAttributeName:UIColor.grayColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(17)]
        let groupTitle:String! = self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
        let numberofAssets:Int = self.group.numberOfAssets()
        
        let attributedString:NSMutableAttributedString! = NSMutableAttributedString(string: "\(groupTitle) (\(numberofAssets))",attributes: numberofAssetsAttribute)
        attributedString.addAttributes(groupTitleAttribute, range: NSMakeRange(0, groupTitle.characters.count))
        self.textLabel?.attributedText = attributedString
        
        
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    
}
