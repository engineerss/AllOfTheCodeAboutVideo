//
//  ZSAlbumModel.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import AssetsLibrary
import UIKit

public class ZSAlbumModel{
    
    var asset:ALAsset!
    var indexPath:NSIndexPath!
    var assetType:String!
    var isSelect:Bool
    init(data:ALAsset)
    {
        self.asset = data
        self.isSelect = false
        self.assetType = data.valueForProperty(ALAssetPropertyType) as? String
    }
    class func AlbumModel(data:ALAsset)
    {
        ZSAlbumModel(data:data)
    }
    
    
    

}
