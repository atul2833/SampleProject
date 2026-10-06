//
//  PropertyDetailsVC.swift
//  TAGCreditMerchant
//
//

import UIKit
import BSImagePicker
import Photos
import AVKit
import AVFoundation
import CoreLocation

class PropertyDetailsVC: BaseNavigationController, CLLocationManagerDelegate {
    
    @IBOutlet weak var btnLeave: ResponsiveButton!
    
    @IBOutlet weak var btnExtend: ResponsiveButton!
    @IBOutlet weak var addressBtn: ResponsiveButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblUserType: UILabel!
    @IBOutlet weak var lblNameUser: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewUser: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    @IBOutlet weak var lblBath: UILabel!
    @IBOutlet weak var lblBeds: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topDescription: NSLayoutConstraint!
    @IBOutlet weak var bottomScrollView: NSLayoutConstraint!
    @IBOutlet weak var heightTblView: NSLayoutConstraint!
    @IBOutlet weak var heightCollView: NSLayoutConstraint!
    @IBOutlet weak var btnBookingRequest: ResponsiveButton!
    @IBOutlet weak var btnsStackView: UIStackView!
    @IBOutlet weak var viewBtns: UIView!
    
    var locationManager: CLLocationManager!

    private var viewModel: RentalViewModel
    let currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
    private var propertyId: String
    private var propertyStatus: String

    private var selectedProperty: PropertyDataModel?

    init(viewModel: RentalViewModel,propertyId:String,propertyStatus:String) {
        self.viewModel = viewModel
        self.propertyId = propertyId
        self.propertyStatus = propertyStatus
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
//        if propertyStatus == "available" {
//            btnsStackView.isHidden = true
//            btnLeave.isUserInteractionEnabled = false
//            btnExtend.isUserInteractionEnabled = false
//            btnBookingRequest.isHidden = false
//        } else {
//            btnsStackView.isHidden = false
//            btnLeave.isUserInteractionEnabled = true
//            btnExtend.isUserInteractionEnabled = true
//            btnBookingRequest.isHidden = true
//
//        }
                    btnsStackView.isHidden = true
                  btnLeave.isUserInteractionEnabled = false
                  btnExtend.isUserInteractionEnabled = false
                    btnBookingRequest.isHidden = false
     
        self.navigationItem.title = "Property Detail"
        
        stateObserver()
        
        collectionView.register(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionViewCell")
        
        tblView.register(UINib(nibName: "SpecificationTblCell", bundle: nil), forCellReuseIdentifier: "SpecificationTblCell")
        
        tblView.removeExtraTopPadding()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getPropertyDetailsData(propertyId: propertyId)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.heightTblView.constant = self.tblView.contentSize.height
            
            let propertyItem = self.viewModel.getPropertyDetails()
            let propertyMediaList = propertyItem?.propertyMediaList
            
            let count1 = (propertyMediaList?.count ?? 0) / 2
            let count2 = (propertyMediaList?.count ?? 0) % 2
        
            let count3 = count1 + count2

            self.heightCollView.constant = ((self.collectionView.frame.size.width / 2) - 18) * CGFloat(count3)

        }
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .listFetched:
                    self?.setPropertiesData()
                case .request(let groupId):
                    self?.sendToChatView(groupId:groupId)
                case .success(let message):
                    self?.navigationController?.popViewController(animated: true)
                case .error(let message):
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
    
    func setPropertiesData(){
        let item = viewModel.getPropertyDetails()
        
       imgView.sd_setImage(with: item?.propertyImageURL)
       lblTitle.text = item?.title
       lblDuration.text = "/\(item?.rentType ?? "")"
       lblDescription.text = item?.description
       lblPrice.text = "\(currency ?? "")\(item?.price ?? "")"
        
        lblBeds.text = "\(item?.bedRooms ?? "") Beds"
        lblBath.text = "\(item?.bathRooms ?? "") Bath"
        lblArea.text = "\(item?.bedRooms ?? "") Sqft"

       let userData = item?.userData
        lblNameUser.text = userData?.fullName
        lblUserType.text = userData?.userType
        imgUser.sd_setImage(with: userData?.profileImageUrl)

       let addressData = item?.propertyAddress
       lblAddress.text = "\(addressData?.address1 != nil ? (addressData?.address1 ?? "") : "")\(addressData?.address2 != nil ? (" ,\(addressData?.address2 ?? "")") : "")\(addressData?.city != nil ? (" ,\(addressData?.city ?? "")") : "")\(addressData?.pincode != nil ? (" ,\(addressData?.pincode ?? "")") : "")"
        
        self.tblView.reloadData()
        self.collectionView.reloadData()
        DispatchQueue.main.async {
            self.viewDidLayoutSubviews()
        }
    }
    
    @IBAction func chatBtnAction(_ sender: ResponsiveButton) {
        selectedProperty = viewModel.getPropertyDetails()
        viewModel.rentPropertyRequest(propertyId: self.propertyId)
       
    }
    
    @IBAction func callBtnAction(_ sender: ResponsiveButton) {
        let item = viewModel.getPropertyDetails()
        let userData = item?.userData
        let phoneNumber = "\(userData?.countryCode ?? "")\(userData?.phoneNumber ?? "")"
                guard let url = URL(string: "tel:\(phoneNumber)"), UIApplication.shared.canOpenURL(url) else {
                    print("Cannot open the dialer or invalid phone number")
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func editBtnAction(_ sender: ResponsiveButton) {
       extendPopup()
    }
    
    
    @IBAction func locationBtnAction(_ sender: ResponsiveButton) {
        locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func deleteBtnAction(_ sender: ResponsiveButton) {
        leavePopup()
    }
    
    @IBAction func bookingRequestBtnAction(_ sender: ResponsiveButton) {
        
        selectedProperty = viewModel.getPropertyDetails()
        viewModel.rentPropertyRequest(propertyId: self.propertyId)
    }
    
    func sendToChatView(groupId:String){
        
        var item = MessageResponseSubDataModel()
        var messageData = MessageDataModel()
        messageData.groupId = groupId
        messageData.propertyData = selectedProperty
        item.messageData = messageData
        let vc = MessageDetailVC(viewModel: MessageViewModel(), messageData: item, type: "propertyRequest")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func leavePopup(){
        let vc = CustomAlertConfirmVC()
            vc.comingTitle = "Leave Property"
            vc.comingDescription = "Are you sure you want to leave this property?"
            vc.comingImage = "Group 71528"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Leave"
        self.presentOnViewController(with: vc)
    }
    
    func extendPopup(){
        let vc = CustomAlertConfirmVC()
            vc.comingTitle = "Extend Property"
            vc.comingDescription = "Are you sure you want to extend this property?"
            vc.comingImage = "Group 71528"
            vc.alertConfirm = self
            vc.yesBtnTitle = "Extend"
        self.presentOnViewController(with: vc)
    }
    
    private func generateThumbnail(from url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)
        var actualTime = CMTime.zero

        do {
            let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: &actualTime)
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            return UIImage()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            print("Current Location: \(latitude), \(longitude)")
            
            // Stop updating location if you only need it once
            locationManager.stopUpdatingLocation()
        }
        
        // Delegate method to handle location errors
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
}

extension PropertyDetailsVC:AlertConfimDelegate{
    func alertAction(_ status: String) {
        if status == "Leave" {
            self.viewModel.leaveProperty(propertyId: propertyId)
        } else {
            self.viewModel.extendProperty(propertyId: self.propertyId)

        }
    }
}

extension PropertyDetailsVC: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let propertyItem = viewModel.getPropertyDetails()
        let specificationData = propertyItem?.specificationList

        return specificationData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "SpecificationTblCell", for: indexPath) as! SpecificationTblCell
        
        let propertyItem = viewModel.getPropertyDetails()
        let item = propertyItem?.specificationList?[indexPath.row]
       
        cell.lblTitle.text = item
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
}

extension PropertyDetailsVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let propertyItem = viewModel.getPropertyDetails()
        let propertyMediaList = propertyItem?.propertyMediaList
        
        return propertyMediaList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        
        let propertyItem = viewModel.getPropertyDetails()
        let item = propertyItem?.propertyMediaList?[indexPath.row]
        
        let url = URL(string: String(format: "%@%@", ServerConfiguration.shared.baseImageURL, item?.value ?? ""))

        if item?.type == "image"{
            cell.imgView.sd_setImage(with: url)
            cell.imgVideo.isHidden = true
        }
        else{
            cell.imgVideo.isHidden = false

            if let url = url {
                generateThumbnail(from: url) { thumbnail in
                       if let thumbnail = thumbnail {
                           // Use the thumbnail (e.g., display it in an image view)
                           cell.imgView.image = thumbnail
                       } else {
                           print("Failed to generate thumbnail")
                       }
                   }

            }
        }
            
        return cell
    }
    
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            do {
                let cgImage = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    func playVideo(url: URL) {
           let player = AVPlayer(url: url)
           let playerViewController = AVPlayerViewController()
           playerViewController.player = player
           
           // Present the view controller
           self.present(playerViewController, animated: true) {
               playerViewController.player?.play()
           }
       }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/2 - 7), height: (collectionView.frame.size.width/2) - 24)
    }
}
