//
//  ZSAlbum.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import Foundation
import AssetsLibrary

public class ZSAlbum{
    //定义block
    public typealias albumGroupsBlock = (groups:NSMutableArray)->()
    public typealias albumAssetsBlock = (assets:NSMutableArray)->()
    

    //定义类的存储属性
    
    var assetsGroup:ALAssetsGroup!
    var assetsLibrary:ALAssetsLibrary!
    var assetsFilter:ALAssetsFilter!
    var groups:NSMutableArray!
    var assets:NSMutableArray!
    
    
    public class func sharedAlbum()->ZSAlbum!
    {
        struct ZSAblumStruct{
        
            static var ablum:ZSAlbum!
            static var onceToken:dispatch_once_t = 0
        }
  
        dispatch_once(&ZSAblumStruct.onceToken , { () -> Void in
            ZSAblumStruct.ablum = ZSAlbum()
            ZSAblumStruct.ablum.assetsLibrary = ALAssetsLibrary()
            ZSAblumStruct.ablum.assetsFilter = ALAssetsFilter.allAssets()
            
        })
        return ZSAblumStruct.ablum
        
        
        
    }
//    取出系统的照片
    public func setupAblumGroups(albumGroups:albumGroupsBlock)
    {
        let groups = NSMutableArray()
        
        let resultBlock:ALAssetsLibraryGroupsEnumerationResultsBlock = {(group:ALAssetsGroup!,stop:UnsafeMutablePointer<ObjCBool>)->Void in
        
            if group != nil {
                group.setAssetsFilter(self.assetsFilter)
                let groupType = group.valueForProperty(ALAssetsGroupPropertyType).integerValue
                if UInt32(groupType) == ALAssetsGroupSavedPhotos {
                    groups.insertObject(group, atIndex: 0)
                    
                }else
                {
                    if group.numberOfAssets()>0 {
                        groups.addObject(group)
                    }
                }
            }else
            {
                self.groups = groups
                albumGroups(groups: groups)
            
            }
            
        }
        let failureBlock:ALAssetsLibraryAccessFailureBlock = {(error:NSError!)->Void in
        
            self.groups = groups
            albumGroups(groups: groups)
            
            
        }
        self.assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: resultBlock, failureBlock: failureBlock)
    }
    
    //    取出系统的照片
    
    public func setUpAlbumAssets(group:ALAssetsGroup,albumAssets:albumAssetsBlock)
    {
        let assets = NSMutableArray()
        group.setAssetsFilter(self.assetsFilter)
        
        let assetsCount = group.numberOfAssets()
        let resultBlock:ALAssetsGroupEnumerationResultsBlock = {(asset:ALAsset!,index:Int,stop:UnsafeMutablePointer<ObjCBool>)->Void in
        
            if asset != nil {
                let model:ZSAlbumModel = ZSAlbumModel(data: asset)
                assets.addObject(model)
                let assetType:String! = model.asset.valueForProperty(ALAssetPropertyType) as? String
                if assetType == ALAssetTypePhoto {
                    
                }else if assetType == ALAssetTypeVideo
                {
                    
                }
                
            }else if assets.count >= assetsCount
            {
                self.assets = assets
                albumAssets(assets: assets)
                
            }
        }
      group.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: resultBlock)    
        
    }
    
    
    
    
    
    
    
    

}