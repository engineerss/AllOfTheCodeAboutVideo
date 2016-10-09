//
//  ZSAlbumPickerCell.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//

import UIKit
import Foundation
import AssetsLibrary


class ZSAlbumPickerCell: UICollectionViewCell
{
    var model:ZSAlbumModel!{
        didSet{
            if model.assetType == ALAssetTypeVideo {
                self.bottomView.hidden = false
                self.bottomView.interval = model.asset.valueForProperty(ALAssetPropertyDuration).doubleValue
            }else
            {
                self.bottomView.hidden = true
            }
            self.imageView.image = UIImage(CGImage: model.asset.thumbnail().takeUnretainedValue())
        
        }
    }
    
    private var imageView:UIImageView!{
        didSet{
        self.addSubview(imageView)
        }
    }

    private var statusView:UIImageView!{
    
        didSet{
        
            statusView.image = UIImage(named: "AlbumPicker.bundle/CardPack_Add_UnSelected@2x")
            self.addSubview(statusView)
        }
    }
    
    private var bottomView:ZSAlbumCelBottomView!{
    
        didSet{
        
            bottomView.backgroundColor = UIColor(red: 19.0/255.0, green: 9.0/255.0, blue: 9.0/255.0, alpha: 0.75)
            self.addSubview(bottomView)
        }
    }
    
    private func setup(){
    
        self.imageView = UIImageView()
        self.statusView = UIImageView()
        self.bottomView = ZSAlbumCelBottomView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupIsSelect(){
    
        if self.selected{
        
            self.statusView.image = UIImage(named:"AlbumPicker.bundle/FriendsSendsPicturesSelectYIcon@2x")
            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.statusView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                }, completion: { (finished) -> Void in
                    UIView.animateWithDuration(0.15, delay: 0.0, options:  UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                        self.statusView.transform = CGAffineTransformMakeScale(1.2, 1.2);
                        }, completion: { (finished) -> Void in
                            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                                self.statusView.transform = CGAffineTransformIdentity;
                                }, completion: { (finished) -> Void in
                                    
                            })
                    })
            })
        }else
        {
            self.statusView.image = UIImage(named: "AlbumPicker.bundle/CardPack_Add_UnSelected@2x")
        }
    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = CGRectMake(0, 0, ZSSwiftDefine.ViewSize(self).width, ZSSwiftDefine.ViewSize(self).height)
        self.statusView.frame = CGRectMake(ZSSwiftDefine.ViewSize(self).width-30, 0, 30, 30)
        self.bottomView.frame = CGRectMake(0, ZSSwiftDefine.ViewSize(self).height-20, ZSSwiftDefine.ViewSize(self).width, 20)
        
    }
    
}


class ZSAlbumCelBottomView:UIView{

    var interval:Double = 0{
        didSet{
        
            var hour:Int = 0
            var minute:Int = 0
            var second:Int = 0
            hour = Int(interval/3600.00)
            minute = Int((interval - Double(3600*hour))/60.00)
            second = Int((interval - Double(3600*hour))%60)
            if hour > 0{
                self.videoTime.text = String(format:"%02d:%02d:%02d", arguments: [hour,minute,second])
            }
            else{
                self.videoTime.text = String(format:"%02d:%02d", arguments: [minute,second])
            }

        }
    }
    
    private var videoImage:UIImageView!{
    
        didSet{
        self.addSubview(videoImage)
            
        }
    }
    private var videoTime:UILabel!{
        didSet{
        videoTime.font = UIFont.systemFontOfSize(14)
            videoTime.textColor = UIColor.whiteColor()
            videoTime.textAlignment = NSTextAlignment.Right
            self.addSubview(videoTime)
        
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
        
        
        
    }
    private func setup()
    {
        self.videoTime = UILabel()
        self.videoImage = UIImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoImage.frame = CGRectMake(0, 0, 20, ZSSwiftDefine.ViewSize(self).height)

         self.videoTime.frame = CGRectMake(ZSSwiftDefine.ViewOrigin(self.videoImage).x+ZSSwiftDefine.ViewSize(self.videoImage).width, 0, ZSSwiftDefine.ViewSize(self).width-ZSSwiftDefine.ViewSize(self.videoImage).width-5, ZSSwiftDefine.ViewSize(self).height)
    }
}

protocol ZSPickerButtomViewDelegate:class {
    func previewButtonClick()
    func sendButtonClick()
}
class ZSPickerButtomView: UIView {
    weak var delegate:ZSPickerButtomViewDelegate!
    private var previewButton:UIButton!{
        didSet{
            previewButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            previewButton.setTitleColor(UIColor(red: 168.0/255.0, green: 168.0/255.0, blue: 168.0/255.0, alpha: 1), forState: UIControlState.Disabled)
            previewButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
            previewButton.setTitle("预览", forState: UIControlState.Normal)
            previewButton.addTarget(self, action: #selector(ZSPickerButtomView.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(previewButton)
        }
    }
    
    private var sendButton:ZSSendButton!{
        didSet{
            
            sendButton.setTitle("发送", forState: UIControlState.Normal)
            sendButton.addTarget(self, action: #selector(ZSPickerButtomView.buttonClick(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(sendButton)
        
        }
    
    
    }
    func buttonClick(sender:UIButton)
    {
        if sender == self.previewButton {
            if delegate != nil {
                delegate.previewButtonClick()
            }
        }else if sender == self.sendButton
        {
            if delegate != nil {
                delegate.sendButtonClick()
            }
        }
        
    }
    func setSendNumber(number:Int)
    {
        self.sendButton.setSendNumber(number)
        if number == 0 {
            self.previewButton.enabled = false
        }else
        {
            self.previewButton.enabled = true
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
        
        self.backgroundColor = UIColor.purpleColor()
        self.previewButton = UIButton(type: .System)
        self.sendButton = ZSSendButton()
        
    }
    
    override func layoutSubviews() {
    super.layoutSubviews()
        self.previewButton.frame = CGRectMake(0, 0, 60, ZSSwiftDefine.ViewSize(self).height)
        self.sendButton.frame = CGRectMake(ZSSwiftDefine.ViewSize(self).width-80, 0, 80, ZSSwiftDefine.ViewSize(self).height)
        
    }
    
    
    
    
    
    
    
    
    
    
    
}


class ZSSendButton: UIButton {
    private var numbersLabel:UILabel!{
        didSet{
        numbersLabel.textColor = UIColor.whiteColor()
        numbersLabel.textAlignment = NSTextAlignment.Center
        numbersLabel.font = UIFont.boldSystemFontOfSize(14.0)
        self.addSubview(numbersLabel)
        
        }
    
    }
    
    private var numbersView:UIView!{
    
        didSet{
        
            numbersView.frame = CGRectMake(0, 12, 20, 20)
            numbersView.backgroundColor = UIColor.greenColor()
            numbersView.layer.cornerRadius = 10.0
            numbersView.clipsToBounds = true
            self.addSubview(numbersView)
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setSendNumber(number:Int) {
        if number == 0{
            self.enabled = false
            self.isHiddenNumber(true)
        }
        else{
            self.enabled = true
            self.isHiddenNumber(false)
        }
        
        self.numbersLabel.text = "\(number)"
        UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.numbersView.transform = CGAffineTransformMakeScale(0.1, 0.1)
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                self.numbersView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.numbersView.transform = CGAffineTransformIdentity
                }) { (finished) -> Void in
                    
                }
            }
        }
    }

    
    private func isHiddenNumber(hidden:Bool){
        self.numbersView.hidden = hidden
        self.numbersLabel.hidden = hidden
    }
    
    private func setup(){
        self.setTitleColor(UIColor(red: 9.0/255.0, green: 187.0/255.0, blue: 7.0/255.0 , alpha: 1), forState: UIControlState.Normal)
        self.setTitleColor(UIColor(red: 182.0/255.0, green: 225.0/255.0, blue: 187.0/255.0, alpha: 1), forState: UIControlState.Disabled)
        self.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        numbersView = UIView()
        numbersLabel = UILabel()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.numbersLabel.frame = CGRectMake(0, 12, 20, 20)
    }


    
}














