//
//  ZSAlbumPicker.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import UIKit
import Foundation
import AssetsLibrary

protocol ZSAlbumPickerDelegate:class {
    func AlbumPickerDidFinishPick(assets:NSArray)
    
}

class ZSAlbumPicker: UIViewController
{
    let thumbNailLength:CGFloat = (UIScreen.mainScreen().bounds.size.width - 5*5)/4
    let albumPickerCellIdentifer:String = "albumPickerCellIdentifer"
    var group:ALAssetsGroup!
    var maxminumNumber:Int = 0
    weak var delegate:ZSAlbumPickerDelegate!
    
    var albumAssets:NSMutableArray!
    var assetsSort:NSMutableArray!
    var selectedAsets:NSMutableArray!{
    
        get{
        
            var selectArray = NSMutableArray()
            var index:NSIndexPath!
            for index in self.assetsSort {
                
                selectArray.addObject(self.albumAssets[index.item])
                
            }
            
        return selectArray
        }
    
    }
    
    var selectNumber:Int = 0{
    
        didSet{
            self.pickerButtonView.setSendNumber(selectNumber)
        }
    }
    
    var pickerButtonView:ZSPickerButtomView!{
    
        didSet{
            
        pickerButtonView.delegate = self
            pickerButtonView.backgroundColor = UIColor.brownColor()
        pickerButtonView.setSendNumber(self.selectNumber)
        self.view.addSubview(pickerButtonView)
        
        }
    
    }
    
    var flowLayout:UICollectionViewFlowLayout!{
    
        didSet{
            flowLayout.itemSize = CGSizeMake(self.thumbNailLength, self.thumbNailLength)
            flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
            flowLayout.minimumLineSpacing = 5
            flowLayout.minimumInteritemSpacing = 5
            
        }
    }
    
    var albumView:UICollectionView!{
        didSet{
        albumView.allowsMultipleSelection = true
        albumView.delegate = self
         albumView.dataSource = self
            albumView.backgroundColor = UIColor.whiteColor()
            albumView.alwaysBounceVertical = true
            albumView.registerClass(ZSAlbumPickerCell.classForCoder(), forCellWithReuseIdentifier: self.albumPickerCellIdentifer)
            self.view.addSubview(albumView)
            
            
        
        }
    
    }
    
    private func setup()
    {
        self.title = self.group.valueForProperty(ALAssetsGroupPropertyName) as? String
        self.assetsSort = NSMutableArray()
        self.flowLayout = UICollectionViewFlowLayout()
        self.albumView = UICollectionView(frame: CGRectMake(0, 0, ZSSwiftDefine.ViewSize(self.view).width, ZSSwiftDefine.ViewSize(self.view).height-44), collectionViewLayout:self.flowLayout)
        self.pickerButtonView = ZSPickerButtomView(frame: CGRectMake(0, ZSSwiftDefine.ViewSize(self.view).height-44, ZSSwiftDefine.ViewSize(self.view).width, 44))
        
        ZSAlbum.sharedAlbum().setUpAlbumAssets(self.group) { (assets)->() in
            self.albumAssets = assets
            self.albumView.reloadData()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.selectNumber = (self.albumView.indexPathsForSelectedItems()?.count)!
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
