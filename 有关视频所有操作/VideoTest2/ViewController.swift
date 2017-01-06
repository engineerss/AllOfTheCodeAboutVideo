//
//  ViewController.swift
//  VideoTest2
//
//  Created by zs mac on 16/7/26.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import Alamofire
import AVFoundation
import AssetsLibrary
import UIKit

class ViewController: UIViewController {

    
    var fileName:String = ""
    var outfilePath:String = ""
    var filePath:String = ""
    var filePathURL:URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
   
    
    
    @IBAction func startLivingBtnClick(_ sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let  vc =  sb.instantiateViewController(withIdentifier: "StartLiveVCID") as! StartLiveVC
//        let navagation:ZSNavigationController = ZSNavigationController(rootViewController:vc)
        self.navigationController?.pushViewController(vc, animated: true);
//        self.presentViewController(navagation, animated: true, completion: nil
//        )

        
        
    }
    
    
    @IBAction func PlayNetWorkBtnClick(_ sender: AnyObject) {
        
      let sb = UIStoryboard(name: "Main", bundle: nil)
      let  vc =  sb.instantiateViewController(withIdentifier: "PlayNetWorkID") as! PlayNetWorkVideo
      let navagation:ZSNavigationController = ZSNavigationController(rootViewController:vc)
      self.present(navagation, animated: true, completion: nil
        )

        
        
    }
    
    
    @IBAction func tableViewVideoBtnClick(_ sender: AnyObject)
    {
        
        let sb = UIStoryboard(name: "Main",bundle: nil);
        let vc = sb.instantiateViewController(withIdentifier: "TableViewVideoSB") as! ZSTableViewController
        let navagation:ZSNavigationController = ZSNavigationController(rootViewController: vc);
        self.present(navagation, animated: true, completion: nil);
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

