//
//  ScanIdBackVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit
import AVFoundation

class ScanIdBackVC: BaseNavigationController{
    
    @IBOutlet weak var lbl: UILabel!
    
    @IBOutlet weak var backView:UIView!

    var qrCodeFrameView: UIView?
    var coming_from = String()

    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var is_qr_scanned = false

  
    
    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
//    lazy var viewModel: ScanViewModel = {
//        return ScanViewModel()
//    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
      //  lbl.text = coming_from == "Receive" ? "Please ask the sender to scan the QR Code".localized : "Scan QR code to pay".localized
       
       // self.navigationItem.title = "Scan QR code to pay"
        initView()
      //  initVM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        self.navigationItem.rightBarButtonItems = []
       // viewModel.is_qr_scanned = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        

    }
    
    func initView(){
        DispatchQueue.main.async{
            guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
                print("Failed to get the camera device")
                return
            }
            
            do {
                // Get an instance of the AVCaptureDeviceInput class using the previous device object.
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                // Set the input device on the capture session.
                self.captureSession.addInput(input)
                
                // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
                let captureMetadataOutput = AVCaptureMetadataOutput()
                self.captureSession.addOutput(captureMetadataOutput)
                
                // Set delegate and use the default dispatch queue to execute the call back
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.supportedCodeTypes
    //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            }
            catch {
                // If any error occurs, simply print it out and don't continue any more.
                print(error)
                return
            }
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session:self.captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.videoPreviewLayer?.frame = self.view.layer.bounds
          //  self.backView.layer.addSublayer(self.videoPreviewLayer!)
            
            DispatchQueue.global(qos: .background).async {
                
                self.captureSession.startRunning()
            }
            self.qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = self.qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                self.backView.addSubview(qrCodeFrameView)
                self.backView.bringSubviewToFront(qrCodeFrameView)
            }
        }
    }
    
    
//    func initVM() {
//        
//        // Naive binding
//        viewModel.showAlertClosure = { [weak self] () in
//            DispatchQueue.main.async {
//                if let message = self?.viewModel.alertMessage {
//                    self?.view.makeToast(message: message)
//                    //self?.showAlert( message )
//                }
//            }
//        }
//        
//        viewModel.updateLoadingStatus = { [weak self] () in
//            DispatchQueue.main.async {
//                let isLoading = self?.viewModel.isLoading ?? false
//                if isLoading {
//                    self?.pleaseWait()
//                }else {
//                    self?.clearAllNotice()
//                }
//            }
//        }
//        
//        viewModel.updateSuccessStatus = { [weak self] () in
//            DispatchQueue.main.async {
//                let vc = PayAmountVC()
//                    vc.receiverInfo = self?.viewModel.receiverInfo
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
//        
////        viewModel.initFetch()
//        
//    }
    
    @IBAction func crossBtnAction(_ sender:ResponsiveButton){
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func qrCodeAction(_ sender:UIButton){
//       let vc = ScanFaceVC()
        let vc = VerifyInformationVC(viewModel: VerifyIdentityViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func scanFromImageAction(_ sender:UIButton){
        let imagePicker = UIImagePickerController()

        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
      //  imagePicker.cameraDevice = .front
        imagePicker.allowsEditing =  false
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension ScanIdBackVC: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
           // messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                
//                if isQRActive{
                    if !is_qr_scanned{
                        is_qr_scanned = true
                        //getUserInfo(code: metadataObj.stringValue!)
                    }
//                }
            }
        }
    }
}

extension ScanIdBackVC:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        if let qrcodeImg = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:qrcodeImg)!
            var qrCodeLink=""
            
            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }
            
            if qrCodeLink=="" {
                print("nothing")
            }else{
                print("message: \(qrCodeLink)")
                //viewModel.getUserInfo(code:qrCodeLink)
            }
        }
        else{
            print("Something went wrong")
        }
        self.dismiss(animated: true, completion: nil)
    }
}

