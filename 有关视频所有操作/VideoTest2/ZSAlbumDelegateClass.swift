//
//  ZSAlbumDelegateClass.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import Foundation
import UIKit
import AssetsLibrary
extension ZSAblumCatalog:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ZSAlbumCatalogCell! = tableView.dequeueReusableCellWithIdentifier(self.KALbumCatalogCellIdentifer) as? ZSAlbumCatalogCell
        if cell == nil {
            cell = ZSAlbumCatalogCell(style: UITableViewCellStyle.Value1, reuseIdentifier: self.KALbumCatalogCellIdentifer)
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        cell.group = self.dataArray[indexPath.row] as? ALAssetsGroup
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
        let albumPick:ZSAlbumPicker = ZSAlbumPicker()
        albumPick.group = self.dataArray[indexPath.row] as! ALAssetsGroup
        albumPick.delegate = self
        if self.maximunNumberofSelectionPhoto != 0 {
            albumPick.maxminumNumber = self.maximunNumberofSelectionPhoto
            
        }else if self.maximuNumberofSelectionMedia != 0
        {
            albumPick.maxminumNumber = self.maximuNumberofSelectionMedia
        }
        
        
        self.navigationController?.pushViewController(albumPick, animated: true)
        
        
        
        
        
    }
}

extension ZSAblumCatalog:ZSAlbumPickerDelegate
{
    func AlbumPickerDidFinishPick(assets: NSArray) {
        if self.delegate != nil {
            self.delegate.AlbumDidFinishPick(assets)
            self.backMainView()
        }
    }
}

extension ZSAlbumPicker:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albumAssets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:ZSAlbumPickerCell = (collectionView.dequeueReusableCellWithReuseIdentifier(self.albumPickerCellIdentifer, forIndexPath: indexPath) as? ZSAlbumPickerCell)!
        let model:ZSAlbumModel = (self.albumAssets[indexPath.row] as? ZSAlbumModel)!
        model.indexPath = indexPath
        cell.model = model
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let model:ZSAlbumModel = self.albumAssets[indexPath.row] as! ZSAlbumModel
        model.isSelect != model.isSelect
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ZSAlbumPickerCell
        cell.setupIsSelect()
        self.selectNumber = (collectionView.indexPathsForSelectedItems()?.count)!
          self.assetsSort.addObject(indexPath)
        

    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let model:ZSAlbumModel = (self.albumAssets[indexPath.row] as? ZSAlbumModel)!
        model.isSelect != model.isSelect
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! ZSAlbumPickerCell
        cell.setupIsSelect()
        self.selectNumber = collectionView.indexPathsForSelectedItems()!.count
       self.assetsSort.removeObject(indexPath)
        
        
    
        
        
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.maxminumNumber != 0 {
            if !(self.maxminumNumber > collectionView.indexPathsForSelectedItems()!.count){
                let alert:UIAlertView! = UIAlertView(title: "提示", message: "最多只能选\(self.maxminumNumber)张图片", delegate: nil, cancelButtonTitle: "确定")
                alert.show()
                return false
            }
            return true
        }
        else{
            return true
        }
    }

}


extension ZSAlbumPicker:ZSPickerButtomViewDelegate
{
    func sendButtonClick() {
        if self.delegate != nil {
            let assets:NSMutableArray = NSMutableArray()
            for model in self.selectedAsets {
                assets.addObject((model as! ZSAlbumModel).asset)
            }
            
            self.delegate.AlbumPickerDidFinishPick(assets)
        }
    }

    func previewButtonClick()
    {
        let assetPresview:ZSAssetPreview! = ZSAssetPreview()
        self.navigationController?.pushViewController(assetPresview, animated: true)
        assetPresview.assets = self.selectedAsets
        assetPresview.albumPickerCollection = self.albumView
        assetPresview.delegate = self
        
    }
    
}
extension ZSAlbumPicker:ZSAssetPreviewDelegate
{
    
    func AssetPreviewDidFinishPick(assets: NSArray) {
        if self.delegate != nil {
            self.delegate.AlbumPickerDidFinishPick(assets)
            
        }
    }
}


extension ZSAssetPreviewItem:UIScrollViewDelegate
{
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.assetImageView
    }
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let originalSize = self.previewScrollView.bounds.size
        let contentSize = self.previewScrollView.contentSize
        let offsetX = (originalSize.width > contentSize.width) ? (originalSize.width - contentSize.width): 0
        let offsetY = (originalSize.height > contentSize.height) ? (originalSize.height - contentSize.height) : 0
        assetImageView.center = CGPointMake(contentSize.width/2 + offsetX,(originalSize.height > contentSize.height) ? originalSize.height/2 : contentSize.height/2 + offsetY)
        
        
    }
    
}

extension ZSAssetPreview:UIScrollViewDelegate,ZSAssetPreviewNavBarDelegate,ZSAssetPreviewToolBarDelegate
{
    func selectButtonClick(selectButton: UIButton) {
        if self.previewScroView.decelerating {
            return
        }
    let assetNumber = Int(self.previewScroView.contentOffset.x/ZSSwiftDefine.ViewSize(self.view).width)
    
        let model:ZSAlbumModel = self.assets[assetNumber] as! ZSAlbumModel
    self.previewNavBar.selectButton.selected = !model.isSelect
 
        if !model.isSelect {
            self.albumPickerCollection.selectItemAtIndexPath(model.indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            self.selectedAssets.addObject(model)
            if self.albumPickerCollection.delegate != nil {
                self.albumPickerCollection.delegate?.collectionView!(self.albumPickerCollection, didSelectItemAtIndexPath: model.indexPath)
                
            }
        }else
        {
           self.albumPickerCollection.deselectItemAtIndexPath(model.indexPath, animated: false)
            self.selectedAssets.removeObject(model)
            if self.albumPickerCollection.delegate != nil {
                self.albumPickerCollection.delegate?.collectionView!(self.albumPickerCollection, didDeselectItemAtIndexPath: model.indexPath)
                
            }
        }
        self.previewToolBar.setSendNumber(self.albumPickerCollection.indexPathsForSelectedItems()!.count)
        
        
        
    }
    
    func backButtonClick(backButton: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func sendButtonClick(sendButton: UIButton) {
        if self.delegate != nil {
            let assets:NSMutableArray = NSMutableArray()
            for model in self.selectedAssets {
                assets.addObject((model as! ZSAlbumModel).asset)
            }
            self.delegate.AssetPreviewDidFinishPick(assets)
        }
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let assetNumber = Int(scrollView.contentOffset.x/ZSSwiftDefine.ViewSize(self.view).width)
        let model:ZSAlbumModel = self.assets[assetNumber] as! ZSAlbumModel
        
        self.previewNavBar.selectButton.selected = model.isSelect
    }
    
//    let assetNumber = Int(self.pre)
 
}
extension ZSAssetPreview:ZSAssetPreviewItemDelegate
{
    func hiddenBarControl() {
        self.previewNavBar.hidden = !self.previewNavBar.hidden
        self.previewToolBar.hidden = !self.previewToolBar.hidden
    }
}

















