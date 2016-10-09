//
//  TakeAfilm.swift
//  VideoTest2
//
//  Created by zs mac on 16/8/15.
//  Copyright © 2016年 zs mac. All rights reserved.
//
import AVFoundation
import AssetsLibrary
import UIKit

class TakeAfilm: UIViewController,AVCaptureFileOutputRecordingDelegate
{

    //需要研究一下这个方法的
    typealias PropertyChangeBlock = ((AVCaptureDevice)->())?
    
    let IPhoneWidth = UIScreen.mainScreen().bounds.width
    let IPhoneHeight = UIScreen.mainScreen().bounds.height
    
    //负责输入和输出设备之间的数据传递
    var captureSession:AVCaptureSession?
    
//    负责从AVCaptureDevice获得输入数据
    var captureDeviceInput:AVCaptureDeviceInput?
    
//    视频输出流
    var captureMovieFileOutput:AVCaptureMovieFileOutput?
    
//    相机拍摄预览图层
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer?
    
//    是否允许旋转（在录制过程中禁止屏幕旋转）
    var enableRotation:Bool?
    
//    旋转前的大小
    var lastBounds:CGRect?
//    后台任务标识
    var backgroundTaskIdentifer:UIBackgroundTaskIdentifier?
    
    
    var viewContainer:UIView?
    
    var  isRunning:Bool?
    
    
//    拍照按钮
    var takeButton:UIButton?
    
//    聚焦光标
    var focusCursor:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRunning = false
        
          let rect =  CGRectMake(0, 0, 28, 28)
        let pickPhotoesBtn = UIButton(frame: rect)
        pickPhotoesBtn.tintColor = UIColor.whiteColor()
        pickPhotoesBtn.setTitle("取消", forState: .Normal)
        
        pickPhotoesBtn.addTarget(self, action:#selector(TakeAfilm().cancleVC), forControlEvents: .TouchUpInside)
        let barLeftBtnItem = UIBarButtonItem(customView: pickPhotoesBtn)
     
        self.navigationItem.rightBarButtonItem = barLeftBtnItem
        
        
        viewContainer = UIView(frame: CGRectMake(0,0,IPhoneWidth,IPhoneHeight-40))
        viewContainer?.backgroundColor = UIColor.brownColor()
        self.view.addSubview(viewContainer!)
        
        takeButton = UIButton(type: .Custom)
        takeButton?.frame = CGRectMake(200, IPhoneHeight-40, 100, 20)
        takeButton?.center = (viewContainer?.center)!
        takeButton?.backgroundColor = UIColor.orangeColor()
        takeButton?.setTitle("录制", forState: .Normal)
        takeButton?.addTarget(self, action: #selector(TakeAfilm.takeButtonClick(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(takeButton!)
        
        
        focusCursor = UIImageView(frame: CGRectMake(200, 200, 40, 40))
        focusCursor?.image = UIImage(named: "5951.png")
        
        
        self.viewContainer?.addSubview(focusCursor!)
        
        
        
    }
    func cancleVC()
    {

       
   
        

         self.captureSession?.stopRunning()
        
        
//        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        初始化会话
        captureSession = AVCaptureSession()
        if ((captureSession?.canSetSessionPreset(AVCaptureSessionPreset1280x720)) != nil) {
//            设置分辨率
            
            captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
//        获得输入设备，取得后置摄像头
        let captureDevice = self.getCameraDeviceWithPosition(AVCaptureDevicePosition.Back)
//        默认获取成功了
//        if captureDevice.{
//            print("\(#line)=======获取后摄像头失败=====")
//            
//        }
//        
        //添加一个音频输入设备
        let audioCaptureDevice = AVCaptureDevice.devicesWithMediaType(AVMediaTypeAudio)[0]
        
//        根据输入设备初始化输入对象，用于获得输入数据
        captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        
//        初始化设备输出对象，用于获得输出数据
        let audioCaptureDeviceInput = try? AVCaptureDeviceInput(device: audioCaptureDevice as! AVCaptureDevice)
        
        
        
//        将设备输入添加到会话中
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        if ((captureSession?.canAddInput(captureDeviceInput)) != nil) {
            captureSession?.addInput(captureDeviceInput)
            captureSession?.addInput(audioCaptureDeviceInput)
            let captureConnection = captureMovieFileOutput?.connectionWithMediaType(AVMediaTypeVideo)
            if ((captureConnection?.supportsVideoStabilization) != nil) {
                captureConnection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Auto
                
            }
            
        }
        if ((captureSession?.canAddOutput(captureMovieFileOutput)) != nil) {
           captureSession?.addOutput(captureMovieFileOutput)
            
        }
        
//        创建视频预览层，用于实时展示摄像头状态
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session:self.captureSession)
        let layer = self.viewContainer?.layer
        layer?.masksToBounds = true
        captureVideoPreviewLayer?.frame = (layer?.bounds)!
        captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer?.insertSublayer(captureVideoPreviewLayer!, below: self.focusCursor?.layer)
        enableRotation = true
       
     
        self.addNotificationToCaptureDevice(captureDevice)
        self.addGenstureRecognizer()
        
        
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession?.startRunning()
        
        
        
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
     
        

    }
    override func shouldAutorotate() -> Bool {
        return self.enableRotation!
    }
    
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        let captureConnection = self.captureVideoPreviewLayer?.connection
      

        switch toInterfaceOrientation {
        case .Portrait:
            captureConnection?.videoOrientation = .Portrait
        case .PortraitUpsideDown:
            captureConnection?.videoOrientation = .PortraitUpsideDown
        case .LandscapeRight:
            captureConnection?.videoOrientation = .LandscapeRight
 
        default:
            
            captureConnection?.videoOrientation = .LandscapeLeft
        }

        
        
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        captureVideoPreviewLayer?.frame = (self.viewContainer?.bounds)!
        
    }
    
    func addGenstureRecognizer()
    {
    
        let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(TakeAfilm().tapScreen(_:)))
        self.viewContainer?.addGestureRecognizer(tapGesture)
        
    }
    
   
    func addNotificationToCaptureSession(captureSession:AVCaptureSession)
    {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TakeAfilm.sessionRuntimeError(_:)), name: AVCaptureSessionRuntimeErrorNotification, object: captureSession)
        
    }
    
    // 给输入设备添加通知
    func addNotificationToCaptureDevice(captureDevice:AVCaptureDevice)
    {
        
        self.changeDeviceProperty{ (captureDevice) in
        
          captureDevice.subjectAreaChangeMonitoringEnabled = true
        }

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TakeAfilm().areaChange), name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: captureDevice)
        
        
        
        
    }
    func removeNotification()
    {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
        
    }
    
    func  sessionRuntimeError(notification:NSNotification)
    {
        print("\(#line)=======会话发生错误=====")
        
    }
    
    func tapScreen(tapGesture:UITapGestureRecognizer)
    {
        let point = tapGesture.locationInView(self.viewContainer)
        let cameraPoint = self.captureVideoPreviewLayer?.captureDevicePointOfInterestForPoint(point)
        self.setFocusCursorWithPoint(point)
        self.focusWithMode(AVCaptureFocusMode.AutoFocus, exposureMode: AVCaptureExposureMode.AutoExpose, point: cameraPoint!)
        
    }
    
    func setFocusCursorWithPoint(point:CGPoint)
    {
        self.focusCursor?.center = point
        self.focusCursor?.transform = CGAffineTransformMakeScale(1.5, 1.5)
        self.focusCursor?.alpha = 1.0
        UIView.animateWithDuration(1.0, animations: {
            self.focusCursor?.transform = CGAffineTransformIdentity
            }) { (finish) in
                self.focusCursor?.alpha = 0
        }

        
    }
    func areaChange()
    {
        print("\(#line)=======捕获区域改变====")
    }
    
    func getCameraDeviceWithPosition(position:AVCaptureDevicePosition)->AVCaptureDevice
    {
        
       let camerasArr =  AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for camera in camerasArr {
            if camera.position == position {
                return camera as! AVCaptureDevice
            }
        }
       return  AVCaptureDevice()
        
     
   
    }
    func takeButtonClick(sender:UIButton)
    {
       
        
        
   
         isRunning = !isRunning!
        
        
        if isRunning == false {
            
            print("\(#line)=======zanting=====")
            self.captureMovieFileOutput?.stopRecording()
            
            
        }else
        {
            print("\(#line)=======kaishi=====")
            
        }
        
//        根据设备输出获得链接
        let captureConnection = self.captureMovieFileOutput?.connectionWithMediaType(AVMediaTypeVideo)
        if (self.captureMovieFileOutput?.recording == true) {
            self.enableRotation = false
            if UIDevice.currentDevice().multitaskingSupported
            {
                self.backgroundTaskIdentifer = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                
            }
            
            captureConnection?.videoOrientation = (self.captureVideoPreviewLayer?.connection.videoOrientation)!
            let outputFielPath = NSTemporaryDirectory().stringByAppendingString("myMovie.mov")
            print("存储的路径是\(outputFielPath)")
            let fielUrl = NSURL(fileURLWithPath: outputFielPath)
            self.captureMovieFileOutput?.startRecordingToOutputFileURL(fielUrl, recordingDelegate: self)
          
            
            
            
            
        }else{
            self.captureMovieFileOutput?.stopRecording()
        }
    }
    
    func toggleButtonClick(sender:UIButton)
    {
        let currentDevice = self.captureDeviceInput?.device
        let currentPosition = currentDevice?.position
        self.removeNotificationFromCaptureSession(currentDevice!)
        
        
        var toChangePosition = AVCaptureDevicePosition.Front
        if currentPosition==AVCaptureDevicePosition.Unspecified||currentPosition == AVCaptureDevicePosition.Front {
            
            toChangePosition = AVCaptureDevicePosition.Back
        }
        
        let toChangeDevice = self.getCameraDeviceWithPosition(toChangePosition)
        
        self.addNotificationToCaptureDevice(toChangeDevice)
        
        let toChangeDeviceInput = try? AVCaptureDeviceInput(device:toChangeDevice)
        
        // 改变会话的配置前一定要先开启配置，配置完成后提交配置改变
        
        self.captureSession?.beginConfiguration()
        
        self.captureSession?.removeInput(self.captureDeviceInput)
        
        //添加新的输入对象
        if ((self.captureSession?.canAddInput(toChangeDeviceInput)) != nil) {
            self.captureSession?.addInput(toChangeDeviceInput)
            self.captureDeviceInput = toChangeDeviceInput
            
        }
        self.captureSession?.commitConfiguration()
        
  
        
    }
    
    //视频输出代理
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("\(#line)=======开始录制=====")
    }

    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("\(#line)=======录制完成=====")
        
        self.enableRotation = true
        let lastBackgroundTaskIdentifier = self.backgroundTaskIdentifer
        self.backgroundTaskIdentifer = UIBackgroundTaskInvalid
        let assetsLibrary = ALAssetsLibrary()
        assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(outputFileURL) { (let assetUrl, let error) in
            if error != nil
            {
                print("\(#line)=======保存视频到相册过程中发生错误，错误的信息为=====\(error.localizedDescription)")
            }
            if lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid
            {
                UIApplication.sharedApplication().endBackgroundTask(lastBackgroundTaskIdentifier!)
                print("\(#line)=======成功的保存到视频相册=====")
                
                
            }
        }

    }

    func deviceConnected(notification:NSNotification)
    {
        print("\(#line)=======设备已连接=====")
    }
 
    func deviceDisconnected(notification:NSNotification)
    {
        print("\(#line)=======设备已经断开=====")
    }
    
    func changeDeviceProperty(propertyChange:PropertyChangeBlock)
    {
        let captureDevice = self.captureDeviceInput?.device
    
        if ((try? captureDevice?.lockForConfiguration()) != nil) {
            propertyChange!(captureDevice!)
            captureDevice?.unlockForConfiguration()
        }else
        {
            print("\(#line)=======设置设备属性的过程中发生错误")
        }
    }
    
    //闪光灯模式
    func setFlashMode(flashMode:AVCaptureFlashMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFlashModeSupported(flashMode))
            {
                captureDevice.flashMode = flashMode
                
            }
        }
    }
    //聚焦模式
    func setFocusMode(focusMode:AVCaptureFocusMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFocusModeSupported(focusMode))
            {
                captureDevice.focusMode = focusMode
                
            }
        }
    }
//    曝光模式
    func setExposureMode(exposureMode:AVCaptureExposureMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isExposureModeSupported(exposureMode))
            {
                captureDevice.exposureMode = exposureMode
                
            }
        }
        
    }
    
    func focusWithMode(focusMode:AVCaptureFocusMode,exposureMode:AVCaptureExposureMode,point:CGPoint)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFocusModeSupported(focusMode))
            {
                captureDevice.focusMode = AVCaptureFocusMode.AutoFocus
            }
            if(captureDevice.focusPointOfInterestSupported)
            {
                captureDevice.focusPointOfInterest = point
            }
            if(captureDevice.isExposureModeSupported(exposureMode))
            {
                captureDevice.exposureMode = AVCaptureExposureMode.AutoExpose
            }
            if(captureDevice.exposurePointOfInterestSupported)
            {
                captureDevice.exposurePointOfInterest = point
            }
        }
    }
    
//    func getCameraDeviceWithPosition(position:AVCaptureDevicePosition)->AVCaptureDevice
//    {
//        let cameras = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
//        for camera in cameras {
//            if camera.position == position {
//                return camera as! AVCaptureDevice
//            }
//        }
//        
//    }
    func removeNotificationFromCaptureSession(captureDevice:AVCaptureDevice)
    {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: captureDevice)
        
    }
    

}
























