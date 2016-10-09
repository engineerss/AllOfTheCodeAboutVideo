
//
//  ZSAssetPreviewNavBar.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/27.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import UIKit
import Foundation
import AssetsLibrary
protocol ZSAssetPreviewNavBarDelegate:class {
    func selectButtonClick(selectButton:UIButton)->Void
    func backButtonClick(backButton:UIButton)->Void
}
protocol ZSAssetPreviewToolBarDelegate:class {
    func sendButtonClick(sendButton:UIButton)->Void
}
class ZSAssetPreviewNavBar: UIView
{
    var selectButton:UIButton!{
        didSet{
            selectButton.setImage(UIImage(named: "AlbumPicker.bundle/FriendsSendsPicturesSelectBigNIcon@2x"), forState: UIControlState.Normal)
            selectButton.setImage(UIImage(named: "AlbumPicker.bundle/FriendsSendsPicturesSelectBigYIcon@2x"), forState: UIControlState.Selected)
            selectButton.selected = true
            selectButton.addTarget(self, action: #selector(ZSAssetPreviewNavBar.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(selectButton)
        }
    
    }
    weak var delegate:ZSAssetPreviewNavBarDelegate!
    
    private var backButton:UIButton!{
        didSet{
        backButton.setImage(UIImage(named: "AlbumPicker.bundle/barbuttonicon_back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: #selector(ZSAssetPreviewNavBar.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup()
    {
        self.selectButton = UIButton()
        self.backButton = UIButton()
        
        
    }
    func buttonClick(sender:UIButton)
    {
        if sender == self.selectButton {
            if self.delegate != nil {
                self.delegate.selectButtonClick(sender)
                
            }
        }else if sender == self.backButton
        {
            self.delegate.backButtonClick(sender)
            
        }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.selectButton.frame = CGRectMake(ZSSwiftDefine.ViewSize(self).width-60, (ZSSwiftDefine.ViewSize(self).height-40)/2, 60, 40)
        self.backButton.frame = CGRectMake(0, (ZSSwiftDefine.ViewSize(self).height - 40)/2, 40, 40)
        
        
        
    }

}

class ZSAssetPreviewToolBar:UIView{

    weak var delegate:ZSAssetPreviewToolBarDelegate!
    private var sendButton:ZSSendButton!{
        didSet{
        sendButton.setTitle("发送", forState: UIControlState.Normal)
        sendButton.addTarget(self, action: #selector(ZSAssetPreviewNavBar.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(sendButton)
        
        
        }
    }
    func buttonClick(sender:UIButton){
        if sender == self.sendButton {
            if self.delegate != nil {
                self.delegate.sendButtonClick(sender)
            }
        }
    
    }
    func setSendNumber(number:Int)
    {
        self.sendButton.setSendNumber(number)
    }

   override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    
    }
    func setup()
    {
        self.sendButton = ZSSendButton()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.sendButton.frame = CGRectMake(ZSSwiftDefine.ViewSize(self).width-80, 0, 80, ZSSwiftDefine.ViewSize(self).height)
        
    }
}

protocol ZSAssetPreviewItemDelegate:class {
    func hiddenBarControl()->Void
}
class ZSAssetPreviewItem: UIView {
    
    weak var delegate:ZSAssetPreviewItemDelegate!
    
    
    var asset:ALAsset!{
        didSet{
            assetImageView.image = UIImage(CGImage: asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
            var imageViewHeight:CGFloat = (assetImageView.image?.size.height)! / (assetImageView.image?.size.width)! * previewScrollView.frame.size.width
            var imageViewWidth = previewScrollView.frame.size.width
            assetImageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewHeight)
            assetImageView.center = CGPointMake(assetImageView.center.x, CGRectGetMidY(self.previewScrollView.frame))
        
        }
    }
    var previewScrollView:UIScrollView!{
        didSet{
            previewScrollView.center = CGPointMake(previewScrollView.center.x, CGRectGetMidY(self.frame))
            previewScrollView.delegate = self
            previewScrollView.showsHorizontalScrollIndicator = false
            previewScrollView.showsVerticalScrollIndicator = false
            previewScrollView.minimumZoomScale = 1.0
            previewScrollView.maximumZoomScale = 2.0
            self.addSubview(previewScrollView)
        }
    
    }
    var assetImageView:UIImageView!{
    
        didSet{
        self.previewScrollView.addSubview(assetImageView)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup()
    {
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self,action: #selector(ZSAssetPreviewItem.hiddenBar)))
        self.previewScrollView = UIScrollView(frame: CGRectMake(10, 0, ZSSwiftDefine.ViewSize(self).width-20, ZSSwiftDefine.ViewSize(self).height))
        self.assetImageView = UIImageView()
        
    }
    func hiddenBar(){
        if self.delegate != nil {
            self.delegate.hiddenBarControl()
        }
    }

}





