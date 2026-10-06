//
//  HelpCenterVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 05/02/24.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import BSImagePicker
import Photos

class HelpCenterVC: BaseNavigationController, AlertInfoDelegate {
    
    @IBOutlet weak var collecView:UICollectionView!
    @IBOutlet weak var txtSubject: UITextField!
    @IBOutlet weak var txtView: IQTextView!
    
    var allSubcriptionViews: [UserData] = [
        UserData(id:1,name:"John smith",profileImage: "christopher-campbell-rDEOVtE7vOs-unsplash",status: "Manager"),
        UserData(id:2,name:"John smith",profileImage: "businesswoman-executive-professional-success-concept-1",status:"")
    ]
    
    var selectedImages = [UIImage]()
    var selectedImagesWithData = [Data]()
    var selectedImagesWithName = [String]()

    var selectedSubjectId = String()
    
    private var viewModel: HelpCenterViewModel
   
    init(viewModel: HelpCenterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        txtSubject.delegate = self
        self.viewModel.helpSubjectList()
        viewModel.getUserId()
        stateObserver()
        // Do any additional setup after loading the view.
    }
    
    func initView() {
        self.navigationItem.title = "Help Center"
        collecView.register(UINib(nibName: "HelpCenterCollCell", bundle: nil), forCellWithReuseIdentifier: "HelpCenterCollCell")

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
       // heightCollView.constant = CGFloat((allSubcriptionViews.count / 2) * 65)
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    ProgressHudWrapper.loadingIndicator()
                case .success(let message):
                    ProgressHudWrapper.dismiss()
                   
                    self?.showAlert(message: message)
                    
                case .listFetched:
                    ProgressHudWrapper.dismiss()
                case .error(let message):
                    ProgressHudWrapper.dismiss()
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    break
                }
            }
            .store(in: &self.viewModel.cancellable)
    }
    
    
    @IBAction func chooseBtnAction(_ sender: ResponsiveButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image, .video]
        imagePicker.settings.selection.unselectOnReachingMax = true

        let start = Date()
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            self.selectedImages.removeAll()
            self.selectedImagesWithData.removeAll()
            self.selectedImagesWithName.removeAll()
            
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            for asset in assets {
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: requestOptions) { (image, _) in
                    if let image = image {
                        self.selectedImages.append(image)
                        self.selectedImagesWithData.append(image.jpegData(compressionQuality: 0.5)!)
                        self.selectedImagesWithName.append("image\(NSDate().timeIntervalSince1970).jpg")
                    }
                }
            }
            
            self.collecView.reloadData()
            print("Finished with selections: \(assets)")
        }, completion: {
            let finish = Date()
            print(finish.timeIntervalSince(start))
        })
    }
    
    @IBAction func continueBtnAction(_ sender:ResponsiveButton){
        if selectedSubjectId.count == 0{
            self.view.makeToast("Please select subject!")
        }
        else{
            self.viewModel.updateImages(imageDatas: selectedImagesWithData, fileNames: selectedImagesWithName,helpSubjectId: selectedSubjectId,orderId: "",description: txtView.text ?? "")
        }
    }
    
    func showAlert(message:String){
        let vc = CustomAlertInfoView()
            vc.comingTitle = "Success"
            vc.comingDescription = message
            vc.comingImage = "Group 71526"
            vc.alertConfirm = self
        self.presentOnViewController(with: vc)
    }
    
    func alertInfoAction(_ status: String) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension HelpCenterVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collecView{
            return selectedImages.count
        }
        else{
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HelpCenterCollCell", for: indexPath) as! HelpCenterCollCell
        cell.image.image = selectedImages[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       // sendSwitchAction(slug: slug)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

extension HelpCenterVC:UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let dropDown = DropDown()

        dropDown.anchorView = textField // UIView or UIBarButtonItem
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.dataSource = viewModel.subjectList?.map{$0.title} as! [String]

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            textField.text = item
            self.selectedSubjectId = "\(self.viewModel.subjectList?[index].id ?? "0")"
        }
        dropDown.show()
        return false
    }
}

