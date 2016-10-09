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

class ViewController: UIViewController,ZSAlbumCatalogDelegate {

    
    var fileName:String = ""
    var outfilePath:String = ""
    var filePath:String = ""
    var filePathURL:NSURL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    func AlbumDidFinishPick(assets: NSArray)
    {
        var index:Int = 0
        for asset in assets {
            if (asset as! ALAsset).valueForProperty("ALAssetPropertyType").isEqual("ALAssetTypePhoto")
            {
                
                let IMV = UIImageView(frame: CGRectMake(100,100 + CGFloat(index) * 10, 50, 50))
                
                let img1 = UIImage(CGImage: (asset as! ALAsset).defaultRepresentation().fullScreenImage().takeUnretainedValue())
                IMV.image = img1
                self.view.addSubview(IMV)
                
                index+=1
                
            }
       else if (asset as!ALAsset).valueForProperty("ALAssetPropertyType").isEqual("ALAssetTypeVideo") {
            let url = (asset as! ALAsset).defaultRepresentation().url()
                   print("该方法的所在行数为......\(#line)....输出值为=====\(url)")
               self.turnToMP4WithURL(url)
                
                
                
                
        }
    }
        
        
        
        
        
    }
    
    func turnToMP4WithURL(videoUrl:NSURL)
    {

        let avAsset = AVURLAsset(URL: videoUrl, options: nil)
        let formater = NSDateFormatter()
        formater.dateFormat = "yyyyMMddHHmmss"
      
     
        
        fileName = "output-" + formater.stringFromDate(NSDate()) + ".mp4"
        outfilePath = NSHomeDirectory().stringByAppendingFormat("/Documents/"+fileName)
        
        print("\(#line)=======沙河路径=====\(outfilePath)")
        
        
        let compatiblePresets = AVAssetExportSession.exportPresetsCompatibleWithAsset(avAsset)
        if compatiblePresets.contains(AVAssetExportPresetMediumQuality)
        {
            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
            exportSession?.outputURL = NSURL(fileURLWithPath: outfilePath)
            exportSession?.outputFileType = AVFileTypeMPEG4
            exportSession?.exportAsynchronouslyWithCompletionHandler({ 
                if(exportSession?.status == AVAssetExportSessionStatus.Completed)
                {
                    self.filePath = self.outfilePath
                    self.filePathURL = NSURL(fileURLWithPath: "file://" + self.outfilePath)
//                       print("该方法的所在行数为......\(#line)....输出值为=====\(self.filePath)")
//                     print("该方法的所在行数为......\(#line)....输出值为=====\(self.filePathURL)")
               
//                    获取大小和长度
                    let para = ["contenttype":"application/octet-stream","discription":self.description]
                    
                    self.uploadNetWorkWithParam(para)
                    
                    
                    
                    
                }else{
//                转化失败
                    
                       print("该方法的所在行数为......\(#line)....输出值为=====\(exportSession?.status)")
                     print("该方法的所在行数为......\(#line)....输出值为=====\(exportSession?.error?.localizedDescription)")
              
                }
            })
            
        }
    }
    
    func uploadNetWorkWithParam(dict:NSDictionary)
    {
      
        
        
        self.clearMovieFromDocuments()
//        print("\(#line)=======视频链接=====\(filePathURL)")
        
//       let data = NSData(contentsOfFile: filePath)
//        let data = NSData(contentsOfURL: filePathURL!)
//        
////        print("\(#line)=======视频数据=====\(data)")
//         let parasDic:[String:String] = ["user_id":"12","special_id":"11"]
//        
//        Alamofire.upload(.POST, "http://www.hangge.com/upload.php",headers:parasDic, multipartFormData: { (MultipartFormData) in
//            
//            MultipartFormData.appendBodyPart(fileURL: self.filePathURL!, name: "file", fileName: self.fileName, mimeType: "application/octet-stream")
//
//            
//            
//            }) { (encodingResult) in
//                print("\(#line)=======上传的结果=====\(encodingResult)")
//
//                switch encodingResult{
//                    
//                    
//                case .Success(let upload,_,_):
//                    upload.progress({ (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//                        print("\(#line)=======字节数=====\(bytesWritten)")
//                        
//                        
//                        
//                        print("该方法的所在行数为......\(#line)....输出值为=====\(totalBytesWritten)")
//                        
//                        
//                        
//                        
//                        print("该方法的所在行数为......\(#line)....输出值为=====\(totalBytesExpectedToWrite)")
//                        
//                        
//
//                    })
//                    
//                    print("\(#line)=======上传的upload=====\(upload)")
//                    upload.responseJSON(completionHandler: { (response) in
//                        
//                            print("\(#line)=======上传的response=====\(response)")
//                        if let myjson = response.result.value
//                        {
//                            if myjson as! NSObject == 0
//                            {
//                                print("\(#line)=======上传成功=====")
//                            }else
//                            {
//                                  print("\(#line)=======上传失败=====")
//                            }
//                        }
//                    })
//                    
//                case .Failure(let error):
//                    print("\(#line)=======错误=====\(error)")
//                   
//                    
//                }
//                
//    
//                
//        }
        
//      Alamofire.upload(.POST, "http://www.hangge.com/upload.php",headers: parasDic, file: self.filePathURL!).progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
//        
//      
//        print("\(#line)=======字节数=====\(bytesWritten)")
//        
//        
//        
//           print("该方法的所在行数为......\(#line)....输出值为=====\(totalBytesWritten)")
//        
//        
//        
//        
//        print("该方法的所在行数为......\(#line)....输出值为=====\(totalBytesExpectedToWrite)")
//        
//        
//        
//        
//        
//        }.responseJSON { response in
//            print("\(#line)=======返回数据结果=====\(response)")
//        }
//        
        
    }

//    成功之后清除沙盒文件
    func clearMovieFromDocuments()
    {
        let fileManager = NSFileManager.defaultManager()
        let urlForDocument = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        
        
        
        
        let url = urlForDocument[0] as NSURL
        
        let contentsOfPath = try? fileManager.contentsOfDirectoryAtPath(url.path!) as NSArray
        
        print("\(#line)=======111沙河下面的东西=====\(contentsOfPath)")
        
        for videoName in contentsOfPath! {
            
        let lastName = (videoName.pathExtension as NSString).lowercaseString
            print("\(#line)=======111沙河下面的东西=====\(lastName)")
            
            if lastName == "mp4"
            {
               
               try! fileManager.removeItemAtPath(NSHomeDirectory() + "/Documents/" + (videoName as! String))
                
            }
            

        }
    
    }
    
    
    @IBAction func startLivingBtnClick(sender: AnyObject) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let  vc =  sb.instantiateViewControllerWithIdentifier("StartLiveVCID") as! StartLiveVC
//        let navagation:ZSNavigationController = ZSNavigationController(rootViewController:vc)
        self.navigationController?.pushViewController(vc, animated: true);
//        self.presentViewController(navagation, animated: true, completion: nil
//        )

        
        
    }
    
    @IBAction func openAlbum(sender: AnyObject) {
  
        
        let albumCatalog:ZSAblumCatalog! = ZSAblumCatalog()
        albumCatalog.delegate = self
        let navagation:ZSNavigationController = ZSNavigationController(rootViewController:albumCatalog)
        self.presentViewController(navagation, animated: true, completion: nil)
        

    }
    
    
    @IBAction func shootAfilm(sender: AnyObject) {
        
     let vc = ZSRecordVideoVC()
        let navagation:ZSNavigationController = ZSNavigationController(rootViewController:vc)
        self.presentViewController(navagation, animated: true, completion: nil
        )
        
    }
    
    
    @IBAction func PlayNetWorkBtnClick(sender: AnyObject) {
        
      let sb = UIStoryboard(name: "Main", bundle: nil)
      let  vc =  sb.instantiateViewControllerWithIdentifier("PlayNetWorkID") as! PlayNetWorkVideo
      let navagation:ZSNavigationController = ZSNavigationController(rootViewController:vc)
      self.presentViewController(navagation, animated: true, completion: nil
        )

        
        
    }
    
    
    @IBAction func tableViewVideoBtnClick(sender: AnyObject)
    {
        
        let sb = UIStoryboard(name: "Main",bundle: nil);
        let vc = sb.instantiateViewControllerWithIdentifier("TableViewVideoSB") as! ZSTableViewController
        let navagation:ZSNavigationController = ZSNavigationController(rootViewController: vc);
        self.presentViewController(navagation, animated: true, completion: nil);
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

