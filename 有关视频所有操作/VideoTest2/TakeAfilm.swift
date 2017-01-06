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
    
    let IPhoneWidth = UIScreen.main.bounds.width
    let IPhoneHeight = UIScreen.main.bounds.height
    
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
        
          let rect =  CGRect(x: 0, y: 0, width: 28, height: 28)
        let pickPhotoesBtn = UIButton(frame: rect)
        pickPhotoesBtn.tintColor = UIColor.white
        pickPhotoesBtn.setTitle("取消", for: UIControlState())
        
        pickPhotoesBtn.addTarget(self, action:#selector(TakeAfilm().cancleVC), for: .touchUpInside)
        let barLeftBtnItem = UIBarButtonItem(customView: pickPhotoesBtn)
     
        self.navigationItem.rightBarButtonItem = barLeftBtnItem
        
        
        viewContainer = UIView(frame: CGRect(x: 0,y: 0,width: IPhoneWidth,height: IPhoneHeight-40))
        viewContainer?.backgroundColor = UIColor.brown
        self.view.addSubview(viewContainer!)
        
        takeButton = UIButton(type: .custom)
        takeButton?.frame = CGRect(x: 200, y: IPhoneHeight-40, width: 100, height: 20)
        takeButton?.center = (viewContainer?.center)!
        takeButton?.backgroundColor = UIColor.orange
        takeButton?.setTitle("录制", for: UIControlState())
        takeButton?.addTarget(self, action: #selector(TakeAfilm.takeButtonClick(_:)), for: .touchUpInside)
        self.view.addSubview(takeButton!)
        
        
        focusCursor = UIImageView(frame: CGRect(x: 200, y: 200, width: 40, height: 40))
        focusCursor?.image = UIImage(named: "5951.png")
        
        
        self.viewContainer?.addSubview(focusCursor!)
        
        
        
    }
    func cancleVC()
    {

       
   
        

         self.captureSession?.stopRunning()
        
        
//        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        初始化会话
        captureSession = AVCaptureSession()
        if ((captureSession?.canSetSessionPreset(AVCaptureSessionPreset1280x720)) != nil) {
//            设置分辨率
            
            captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
//        获得输入设备，取得后置摄像头
        let captureDevice = self.getCameraDeviceWithPosition(AVCaptureDevicePosition.back)
//        默认获取成功了
//        if captureDevice.{
//            print("\(#line)=======获取后摄像头失败=====")
//            
//        }
//        
        //添加一个音频输入设备
        let audioCaptureDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio)[0]
        
//        根据输入设备初始化输入对象，用于获得输入数据
        captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        
//        初始化设备输出对象，用于获得输出数据
        let audioCaptureDeviceInput = try? AVCaptureDeviceInput(device: audioCaptureDevice as! AVCaptureDevice)
        
        
        
//        将设备输入添加到会话中
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        if ((captureSession?.canAddInput(captureDeviceInput)) != nil) {
            captureSession?.addInput(captureDeviceInput)
            captureSession?.addInput(audioCaptureDeviceInput)
            let captureConnection = captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
            if ((captureConnection?.isVideoStabilizationSupported) != nil) {
                captureConnection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                
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
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.captureSession?.startRunning()
        
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
     
        

    }
    override var shouldAutorotate : Bool {
        return self.enableRotation!
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        let captureConnection = self.captureVideoPreviewLayer?.connection
      

        switch toInterfaceOrientation {
        case .portrait:
            captureConnection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            captureConnection?.videoOrientation = .portraitUpsideDown
        case .landscapeRight:
            captureConnection?.videoOrientation = .landscapeRight
 
        default:
            
            captureConnection?.videoOrientation = .landscapeLeft
        }

        
        
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        captureVideoPreviewLayer?.frame = (self.viewContainer?.bounds)!
        
    }
    
    func addGenstureRecognizer()
    {
    
        let tapGesture  = UITapGestureRecognizer(target: self, action: #selector(TakeAfilm().tapScreen(_:)))
        self.viewContainer?.addGestureRecognizer(tapGesture)
        
    }
    
   
    func addNotificationToCaptureSession(_ captureSession:AVCaptureSession)
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TakeAfilm.sessionRuntimeError(_:)), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: captureSession)
        
    }
    
    // 给输入设备添加通知
    func addNotificationToCaptureDevice(_ captureDevice:AVCaptureDevice)
    {
        
        self.changeDeviceProperty{ (captureDevice) in
        
          captureDevice.isSubjectAreaChangeMonitoringEnabled = true
        }

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TakeAfilm().areaChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: captureDevice)
        
        
        
        
    }
    func removeNotification()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
        
    }
    
    func  sessionRuntimeError(_ notification:Notification)
    {
        print("\(#line)=======会话发生错误=====")
        
    }
    
    func tapScreen(_ tapGesture:UITapGestureRecognizer)
    {
        let point = tapGesture.location(in: self.viewContainer)
        let cameraPoint = self.captureVideoPreviewLayer?.captureDevicePointOfInterest(for: point)
        self.setFocusCursorWithPoint(point)
        self.focusWithMode(AVCaptureFocusMode.autoFocus, exposureMode: AVCaptureExposureMode.autoExpose, point: cameraPoint!)
        
    }
    
    func setFocusCursorWithPoint(_ point:CGPoint)
    {
        self.focusCursor?.center = point
        self.focusCursor?.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.focusCursor?.alpha = 1.0
        UIView.animate(withDuration: 1.0, animations: {
            self.focusCursor?.transform = CGAffineTransform.identity
            }, completion: { (finish) in
                self.focusCursor?.alpha = 0
        }) 

        
    }
    func areaChange()
    {
        print("\(#line)=======捕获区域改变====")
    }
    
    func getCameraDeviceWithPosition(_ position:AVCaptureDevicePosition)->AVCaptureDevice
    {
        
       let camerasArr =  AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for camera in camerasArr! {
            if (camera as AnyObject).position == position {
                return camera as! AVCaptureDevice
            }
        }
       return  AVCaptureDevice()
        
     
   
    }
    func takeButtonClick(_ sender:UIButton)
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
        let captureConnection = self.captureMovieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
        if (self.captureMovieFileOutput?.isRecording == true) {
            self.enableRotation = false
            if UIDevice.current.isMultitaskingSupported
            {
                self.backgroundTaskIdentifer = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                
            }
            
            captureConnection?.videoOrientation = (self.captureVideoPreviewLayer?.connection.videoOrientation)!
            let outputFielPath = NSTemporaryDirectory() + "myMovie.mov"
            print("存储的路径是\(outputFielPath)")
            let fielUrl = URL(fileURLWithPath: outputFielPath)
            self.captureMovieFileOutput?.startRecording(toOutputFileURL: fielUrl, recordingDelegate: self)
          
            
            
            
            
        }else{
            self.captureMovieFileOutput?.stopRecording()
        }
    }
    
    func toggleButtonClick(_ sender:UIButton)
    {
        let currentDevice = self.captureDeviceInput?.device
        let currentPosition = currentDevice?.position
        self.removeNotificationFromCaptureSession(currentDevice!)
        
        
        var toChangePosition = AVCaptureDevicePosition.front
        if currentPosition==AVCaptureDevicePosition.unspecified||currentPosition == AVCaptureDevicePosition.front {
            
            toChangePosition = AVCaptureDevicePosition.back
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
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("\(#line)=======开始录制=====")
    }

    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("\(#line)=======录制完成=====")
        
        self.enableRotation = true
        let lastBackgroundTaskIdentifier = self.backgroundTaskIdentifer
        self.backgroundTaskIdentifer = UIBackgroundTaskInvalid
        let assetsLibrary = ALAssetsLibrary()
        assetsLibrary.writeVideoAtPath(toSavedPhotosAlbum: outputFileURL) { (assetUrl, error) in
            if error != nil
            {
                print("\(#line)=======保存视频到相册过程中发生错误，错误的信息为=====\(error?.localizedDescription)")
            }
            if lastBackgroundTaskIdentifier != UIBackgroundTaskInvalid
            {
                UIApplication.shared.endBackgroundTask(lastBackgroundTaskIdentifier!)
                print("\(#line)=======成功的保存到视频相册=====")
                
                
            }
        }

    }

    func deviceConnected(_ notification:Notification)
    {
        print("\(#line)=======设备已连接=====")
    }
 
    func deviceDisconnected(_ notification:Notification)
    {
        print("\(#line)=======设备已经断开=====")
    }
    
    func changeDeviceProperty(_ propertyChange:PropertyChangeBlock)
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
    func setFlashMode(_ flashMode:AVCaptureFlashMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFlashModeSupported(flashMode))
            {
                captureDevice.flashMode = flashMode
                
            }
        }
    }
    //聚焦模式
    func setFocusMode(_ focusMode:AVCaptureFocusMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFocusModeSupported(focusMode))
            {
                captureDevice.focusMode = focusMode
                
            }
        }
    }
//    曝光模式
    func setExposureMode(_ exposureMode:AVCaptureExposureMode)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isExposureModeSupported(exposureMode))
            {
                captureDevice.exposureMode = exposureMode
                
            }
        }
        
    }
    
    func focusWithMode(_ focusMode:AVCaptureFocusMode,exposureMode:AVCaptureExposureMode,point:CGPoint)
    {
        self.changeDeviceProperty { (captureDevice) in
            if(captureDevice.isFocusModeSupported(focusMode))
            {
                captureDevice.focusMode = AVCaptureFocusMode.autoFocus
            }
            if(captureDevice.isFocusPointOfInterestSupported)
            {
                captureDevice.focusPointOfInterest = point
            }
            if(captureDevice.isExposureModeSupported(exposureMode))
            {
                captureDevice.exposureMode = AVCaptureExposureMode.autoExpose
            }
            if(captureDevice.isExposurePointOfInterestSupported)
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
    func removeNotificationFromCaptureSession(_ captureDevice:AVCaptureDevice)
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: captureDevice)
        
    }
    

}
























