//
//  KycVC.swift
//  TAGCredit
//
//  Created by Rahul Jangid on 18/09/24.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import BSImagePicker
import Photos

class KycVC: BaseNavigationController {

    //@IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var lblUplodedIdType: UILabel!
    @IBOutlet weak var tfNationalNumber: UITextField!
    @IBOutlet weak var tfNationalId: UITextField!
    @IBOutlet weak var btnProcess: UIButton!
    
    @IBOutlet weak var frontViewBtn: UIButton!
    @IBOutlet weak var backBtnView: UIButton!
    
    
    // MARK: - Image handling
        private enum ImageSide {
            case front
            case back
        }
    
    private var currentSide: ImageSide?

       private var frontImage: UIImage? {
           didSet { updateButtonImage(frontViewBtn, image: frontImage) }
       }
       private var backImage: UIImage? {
           didSet { updateButtonImage(backBtnView, image: backImage) }
       }

       private var frontImageData: Data?
       private var backImageData: Data?
    
    var selectedId = Int()
    var imagePicker = UIImagePickerController()
        
    var selectedImages = [UIImage]()
    var selectedImagesWithData = [Data]()
    var selectedImagesWithName = [String]()
    var commingFrom = String()
    private var viewModel: VerifyIdentityViewModel
    //private var timerLabel: CustomTimerLabel!

    init(viewModel: VerifyIdentityViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        tfNationalId.delegate = self
        self.navigationItem.title = "Complete Your KYC"
        if commingFrom == "fromOTP" {
            isBackToPreviousScreenFromOTP = true
        }
       // collView.register(UINib(nibName: "KycCollCell", bundle: nil), forCellWithReuseIdentifier: "KycCollCell")
        stateObserver()
        self.viewModel.kycDocumentType(page: 1, limit: 5)
        
         if AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool ?? false {
         }
    }
    
    private func stateObserver() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &viewModel.cancellable)
    }
    
    private func handleState(_ state: VerifyIdentityViewModel.State) {
        
        switch state {
        case .loading:
            ProgressHudWrapper.loadingIndicator()
        case .success:
            ProgressHudWrapper.dismiss()
        case .error(let message):
            ProgressHudWrapper.dismiss()
            self.view.makeToast(message, position: .bottom)
        case .kycConfirmSuccess(let message):
            ProgressHudWrapper.dismiss()
            self.view.makeToast(message, position: .bottom)
            handleSuccess()
        default:
            ProgressHudWrapper.dismiss()
        }
    }
    
    func handleSuccess(){
        let vc = SubscriptionVC(viewModel: SubscriptionViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
    }



    @IBAction func btnProcessAction(_ sender: UIButton) {
//        if selectedId.words.isEmpty{
//            self.view.makeToast("Please select Id!")
//        }
//        else{
//            self.viewModel.saveKyc(imageDatas: selectedImagesWithData, fileNames: selectedImagesWithName, nationalIdentityTypeId: "\(selectedId)", nationalIdentityNumber: tfNationalNumber.text ?? "")
//        }
        
        if selectedId.words.isEmpty {
                    self.view.makeToast("Please select Id!")
                    return
                }
                guard frontImageData != nil else {
                    self.view.makeToast("Please upload the front view of your ID!")
                    return
                }
                guard backImageData != nil else {
                    self.view.makeToast("Please upload the back view of your ID!")
                    return
                }

                self.viewModel.saveKyc(
                    imageDatas: selectedImagesWithData,
                    fileNames: selectedImagesWithName,
                    nationalIdentityTypeId: "\(selectedId)",
                    nationalIdentityNumber: tfNationalNumber.text ?? ""
                )
    }
    
    @IBAction func frontViewBtnClicked(_ sender: Any) {
        currentSide = .front
                presentImageSourceOptions()
    }
    
    @IBAction func backViewBtnClicked(_ sender: Any) {
        currentSide = .back
               presentImageSourceOptions()
    }
    
    // MARK: - Source selection (Camera / Gallery)

       private func presentImageSourceOptions() {
           let alert = UIAlertController(title: "Upload Document", message: "Choose an option", preferredStyle: .actionSheet)

           alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
               self?.openCamera()
           })

           alert.addAction(UIAlertAction(title: "Choose from Gallery", style: .default) { [weak self] _ in
               self?.openGallery()
           })

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

           // iPad support
           if let popover = alert.popoverPresentationController {
               popover.sourceView = currentSide == .front ? frontViewBtn : backBtnView
               popover.sourceRect = (currentSide == .front ? frontViewBtn : backBtnView)?.bounds ?? .zero
           }

           present(alert, animated: true)
       }

       private func openCamera() {
           guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
               self.view.makeToast("Camera not available on this device")
               return
           }

           AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               DispatchQueue.main.async {
                   guard let self = self else { return }
                   if granted {
                       let picker = UIImagePickerController()
                       picker.delegate = self
                       picker.sourceType = .camera
                       picker.allowsEditing = true
                       self.present(picker, animated: true)
                   } else {
                       self.view.makeToast("Please allow camera access from Settings to take a photo")
                   }
               }
           }
       }

       private func openGallery() {
           PHPhotoLibrary.requestAuthorization { [weak self] status in
               DispatchQueue.main.async {
                   guard let self = self else { return }
                   switch status {
                   case .authorized, .limited:
                       let picker = UIImagePickerController()
                       picker.delegate = self
                       picker.sourceType = .photoLibrary
                       picker.allowsEditing = true
                       self.present(picker, animated: true)
                   default:
                       self.view.makeToast("Please allow photo library access from Settings to upload a photo")
                   }
               }
           }
       }

       // MARK: - Helpers

       private func updateButtonImage(_ button: UIButton, image: UIImage?) {
           guard let image = image else { return }
           button.setImage(image, for: .normal)
           button.setTitle(nil, for: .normal)
       }

       /// Rebuilds the arrays sent to saveKyc so front is always index 0 and back is always index 1.
       private func syncSelectedImageArrays() {
           selectedImagesWithData.removeAll()
           selectedImagesWithName.removeAll()

           if let frontImageData = frontImageData {
               selectedImagesWithData.append(frontImageData)
               selectedImagesWithName.append("front_\(Int(Date().timeIntervalSince1970)).jpg")
           }
           if let backImageData = backImageData {
               selectedImagesWithData.append(backImageData)
               selectedImagesWithName.append("back_\(Int(Date().timeIntervalSince1970)).jpg")
           }
       }
   
    
    
//    @objc func uploadPhoto(_ sender: UIButton) {
//        let imagePicker = ImagePickerController()
//        imagePicker.settings.selection.max = 2
//        imagePicker.settings.theme.selectionStyle = .numbered
//        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
//        imagePicker.settings.selection.unselectOnReachingMax = true
//
//        let start = Date()
//        self.presentImagePicker(imagePicker, select: { (asset) in
//            print("Selected: \(asset)")
//        }, deselect: { (asset) in
//            print("Deselected: \(asset)")
//        }, cancel: { (assets) in
//            print("Canceled with selections: \(assets)")
//        }, finish: { (assets) in
//            self.selectedImages.removeAll()
//            self.selectedImagesWithData.removeAll()
//            self.selectedImagesWithName.removeAll()
//            
//            let imageManager = PHImageManager.default()
//            let requestOptions = PHImageRequestOptions()
//            requestOptions.isSynchronous = true
//            requestOptions.deliveryMode = .highQualityFormat
//            
//            for asset in assets {
//                imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: requestOptions) { (image, _) in
//                    if let image = image {
//                        self.selectedImages.append(image)
//                        self.selectedImagesWithData.append(image.jpegData(compressionQuality: 0.5)!)
//                        self.selectedImagesWithName.append("image\(NSDate().timeIntervalSince1970).jpg")
//                    }
//                }
//            }
//            
//           // self.collView.reloadData()
//            print("Finished with selections: \(assets)")
//        }, completion: {
//            let finish = Date()
//            print(finish.timeIntervalSince(start))
//        })
//    }
    

}

extension KycVC:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let dropDown = DropDown()

        dropDown.anchorView = textField // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.dataSource = viewModel.kycDocModel?.documentTypeList.map{$0.title} as! [String]

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            textField.text = item
            self.selectedId = self.viewModel.kycDocModel?.documentTypeList[index].id ?? 0
        }
        dropDown.show()
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate

extension KycVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        let picked = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        guard let image = picked, let data = image.jpegData(compressionQuality: 0.5) else {
            self.view.makeToast("Could not process the selected image")
            return
        }

        switch currentSide {
        case .front:
            frontImage = image
            frontImageData = data
        case .back:
            backImage = image
            backImageData = data
        case .none:
            break
        }

        syncSelectedImageArrays()
        currentSide = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        currentSide = nil
    }
}


//extension KycVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if selectedImages.isEmpty {
//            return 2
//        } else {
//            return selectedImages.count
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KycCollCell", for: indexPath) as! KycCollCell
//        if selectedImages.isEmpty {
//            cell.btnUpload.addTarget(self, action: #selector(uploadPhoto(_:)), for: .touchUpInside)
//            cell.imgLogo.isHidden = false
//            cell.lblInfo.isHidden = false
//            if indexPath.item == 0 {
//                cell.lblInfo.text = "Upload Front view"
//            } else {
//                cell.lblInfo.text = "Upload Back view"
//            }
//
//        } else {
//            cell.imgMain.image = selectedImages[indexPath.item]
//            cell.imgLogo.isHidden = true
//            cell.lblInfo.isHidden = true
//
//        }
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//       // sendSwitchAction(slug: slug)
//        
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width/2, height: collectionView.frame.size.height)
//    }
//}
