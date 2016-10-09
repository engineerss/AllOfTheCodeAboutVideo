//
//  ZSAblumCatalog.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import Foundation
import AssetsLibrary
import UIKit

protocol ZSAlbumCatalogDelegate:class{

    func AlbumDidFinishPick(assets:NSArray)->Void
    
}
@objc class ZSAblumCatalog: UIViewController
{
    var KALbumCatalogCellIdentifer:String  = "albumCatalogCellIdentifer"
    
    var maximunNumberofSelectionPhoto:Int = 0
    {
        didSet{
        ZSAlbum.sharedAlbum().assetsFilter = ALAssetsFilter.allPhotos()
        }
    }
    var maximuNumberofSelectionMedia:Int = 0{
    
        didSet{
        
            ZSAlbum.sharedAlbum().assetsFilter = ALAssetsFilter.allAssets()
            
        }
    }
    

    weak var delegate:ZSAlbumCatalogDelegate!
    
 
    var dataArray:NSMutableArray!
    
    private var albumTableView:UITableView!{
        didSet{
            albumTableView.delegate = self
            albumTableView.dataSource = self
            albumTableView.rowHeight = 70
            let imv  = UIImageView(frame: CGRectMake(0, 0, ZSSwiftDefine.ViewSize(self.view).width, ZSSwiftDefine.ViewSize(self.view).height))
            imv.image = UIImage(named: "5951.png")
            albumTableView.backgroundView = imv
            albumTableView.tableFooterView = UIView()
            self.view.addSubview(albumTableView)
            
        
        }
        
    }
    
    private func setup()
    {
        self.dataArray = NSMutableArray()
        self.albumTableView = UITableView(frame: CGRectMake(0, 0, ZSSwiftDefine.ViewSize(self.view).width, ZSSwiftDefine.ViewSize(self.view).height), style: UITableViewStyle.Plain)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "照片"
        self.setup()
        
        ZSAlbum.sharedAlbum().setupAblumGroups { (groups) in
            self.dataArray = groups
            self.albumTableView.reloadData()
        }

   self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ZSAblumCatalog.backMainView))
    }
    func backMainView()
    {
        self.navigationController?.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
