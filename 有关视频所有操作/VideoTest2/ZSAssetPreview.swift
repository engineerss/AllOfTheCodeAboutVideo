//
//  ZSAssetPreview.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/27.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import Foundation
import UIKit
protocol ZSAssetPreviewDelegate:class{
    func AssetPreviewDidFinishPick(assets:NSArray)->Void
    
}
class ZSAssetPreview: UIViewController
{
    var assets:NSMutableArray!
    var albumPickerCollection:UICollectionView!
    weak var delegate:ZSAssetPreviewDelegate!
    var selectedAssets:NSMutableArray!
    var previewScroView:UIScrollView!{
        didSet{
            previewScroView.backgroundColor = UIColor.blackColor()
            previewScroView.pagingEnabled = true
            previewScroView.delegate = self
            previewScroView.showsVerticalScrollIndicator = false
            previewScroView.showsHorizontalScrollIndicator = false
            self.view.addSubview(previewScroView)
        }
    
    }
    
    var previewNavBar:ZSAssetPreviewNavBar!{
        didSet{
        
            previewNavBar.backgroundColor = UIColor.redColor()
            previewNavBar.delegate = self
            self.view.addSubview(previewNavBar)
            
        }
    }
    var previewToolBar:ZSAssetPreviewToolBar!{
    
        didSet{
        previewToolBar.backgroundColor = UIColor.greenColor()
            previewToolBar.delegate = self
            previewToolBar.setSendNumber(self.albumPickerCollection.indexPathsForSelectedItems()!.count)
            self.view.addSubview(previewToolBar)
        }
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    private func setup(){
    
        self.automaticallyAdjustsScrollViewInsets = false
        self.prefersStatusBarHidden()
        self.selectedAssets = NSMutableArray(array: self.assets)
        
        
        
        self.navigationController?.navigationBarHidden = true
        self.previewScroView = UIScrollView(frame: CGRectMake(0,0,ZSSwiftDefine.ViewSize(self.view).width,ZSSwiftDefine.ViewSize(self.view).height))
        self.previewNavBar = ZSAssetPreviewNavBar()
        self.previewToolBar = ZSAssetPreviewToolBar()
        self.setAssets()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    
    private func setAssets(){
    
        self.previewScroView.contentSize = CGSizeMake(ZSSwiftDefine.ViewSize(self.view).width * CGFloat(self.assets.count), ZSSwiftDefine.ViewSize(self.view).height)
        for i in 0 ..< self.assets.count {
            var previewItem :ZSAssetPreviewItem = ZSAssetPreviewItem(frame: CGRectMake(ZSSwiftDefine.ViewSize(self.view).width * CGFloat(i),0, ZSSwiftDefine.ViewSize(self.view).width, ZSSwiftDefine.ViewSize(self.view).height))
            previewItem.delegate = self
            var model:ZSAlbumModel = self.assets[i] as!ZSAlbumModel
            previewItem.asset = model.asset
            self.previewScroView.addSubview(previewItem)

    }
        func viewWillDisappear(animated: Bool) {
            super.viewWillDisappear(animated)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            self.previewNavBar.frame = CGRectMake(0, 0, ZSSwiftDefine.ViewSize(self.view).width,64)
            self.previewToolBar.frame = CGRectMake(0, ZSSwiftDefine.ViewSize(self.view).height-44, ZSSwiftDefine.ViewSize(self.view).width, 44)
        }
    

    
}
}
