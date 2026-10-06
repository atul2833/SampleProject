//
//  LocationPageVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 01/01/24.
//

import UIKit
import MobileCoreServices

struct ScreenSize{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct colorsList{
    static let colors = ["F0F0F0","F7FFF0","FFF6F0","EAF7FF"]
    static let colorsForCollectionView = ["FFEFD1","FC5A86","CE77E8","82DCFD","82FD9A"]
    static let textColor = ["966200","FFFFFF","FFFFFF","006B91","00B53F"]
}

protocol HomeSectionActionDelegate {
    func brandSectionAction(_ sender: UIButton)
    func categorySectionAction(_ sender: UIButton)
    func popularSectionAction(_ sender: UIButton)
    func sectionAction(_ sender: UIButton)
}

struct HomeLayouts {
    static let headerViewHeight: CGFloat = 44
    static let brandViewWidth: CGFloat = 140
    static let brandViewHeight: CGFloat = 100
    static let categoryViewWidth: CGFloat = (ScreenSize.SCREEN_WIDTH - 15) / 3
    static let catrgoryViewHeight: CGFloat = 150
    static let popularProductViewHeight: CGFloat = 160
    static let collectionCellWidth: CGFloat = (ScreenSize.SCREEN_WIDTH - 20) / 3
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

class CustomAlertView: UIView {
    private let gradientLayer = CAGradientLayer()
    // UI elements for the custom alert
    private let imageView = UIImageView()

    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let okButton = UIButton()
    private let separatorLine = UIView()

    // Transparent overlay view
    private let overlayView = UIView()

    var okButtonAction: (() -> Void)?

    // Initialization and setup
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Customize the appearance of the custom alert here
        self.frame = CGRect(x: 30, y: (ScreenSize.SCREEN_HEIGHT / 2) - 100, width: ScreenSize.SCREEN_WIDTH - 60, height: 220)
        self.backgroundColor = UIColor.gray
        self.cornerRadius = 22
        
        imageView.frame = CGRect(x: (self.bounds.size.width / 2) - 18, y: 20, width: 36, height:36)
        imageView.image = UIImage(named: "check")
        addSubview(imageView)

        // Add titleLabel
        titleLabel.frame = CGRect(x: 20, y: 66, width: ScreenSize.SCREEN_WIDTH - 100, height: 30)
        titleLabel.textAlignment = .center
        titleLabel.font = AppFont.medium(.subTitle)
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        addSubview(titleLabel)

        // Add messageLabel
        messageLabel.frame = CGRect(x: 40, y: 96, width: ScreenSize.SCREEN_WIDTH - 140, height: 60)
        messageLabel.textAlignment = .center
        messageLabel.font = AppFont.regular(.subTitle)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.numberOfLines = 3
        addSubview(messageLabel)

        separatorLine.frame = CGRect(x: 0, y: 166, width: ScreenSize.SCREEN_WIDTH - 60, height: 1)
        separatorLine.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        addSubview(separatorLine)
        
        // Add okButton
        okButton.frame = CGRect(x: 20, y: 172, width:ScreenSize.SCREEN_WIDTH - 100, height: 40)
        okButton.setTitle("Okay", for: .normal)
        okButton.backgroundColor = UIColor.clear
        okButton.setTitleColor(UIColor.appBlue, for: .normal)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        addSubview(okButton)
        
        // Configure the transparent overlay view
        overlayView.frame = UIScreen.main.bounds
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0 // Initially hidden
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Function to set the title and message of the custom alert
    func set(title: String, message: String,image:String) {
        titleLabel.text = title
        messageLabel.text = message
        imageView.image = UIImage(named: image)
    }

    @objc private func okButtonTapped() {
           // Call the closure when the OK button is tapped
           okButtonAction?()
           hide()
       }
    
    // Function to handle the OK button tap
//    @objc private func okButtonTapped() {
//        // Handle OK button tap
//        hide()
//    }
    
    // Function to show the custom alert and overlay
    func show() {
        overlayView.alpha = 1 // Show the overlay
        UIApplication.shared.keyWindow?.addSubview(overlayView)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    // Function to hide the custom alert and overlay
    func hide() {
        overlayView.alpha = 0 // Hide the overlay
        removeFromSuperview()
        overlayView.removeFromSuperview()
    }
}

class CustomAlert: UIView {

    // Add your custom UI elements here
    func addImageView(){
        
        let backView = UIView(frame: CGRect(x: 30, y: (ScreenSize.SCREEN_HEIGHT / 2) - 100, width: ScreenSize.SCREEN_WIDTH - 60, height: 200))
        backView.cornerRadius = 22
        let imageView = UIImageView(frame: CGRect(x: 10, y: 50, width: 50, height: 50))
        imageView.image = UIImage(named: "check")
        backView.addSubview(imageView)
        self.addSubview(backView)
    }
    // Function to show the custom alert
    func show(in view: UIView) {
        self.frame = CGRect(x: 0, y: 0, width: 300, height: 200) // Set the frame as needed
        self.center = view.center
        addImageView()
        // Add your custom alert as a subview to the specified view
        view.addSubview(self)

        // You can add an animation to make it appear, for example:
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }

    // Function to dismiss the custom alert
    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
            // Fallback on earlier versions
        }
    }
}

extension UITextField {
    
    @IBInspectable var leftSpaceText: CGFloat {
        get {
            //self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: ne, height: 10))
            return leftView?.frame.size.width ?? 0
        } set {
            //return newValue
            self.leftViewMode = .always
            self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: 10))
        }
    }
    
    @IBInspectable var rightSpaceText: CGFloat {
        get {
            //self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: ne, height: 10))
            return rightView?.frame.size.width ?? 0
        } set {
            //return newValue
            self.rightViewMode = .always
            self.rightView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: 10))
        }
    }
   
    @IBInspectable var placeHolderColr: UIColor? {
        get {
            return self.placeHolderColr
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor : newValue! , NSAttributedString.Key.font : self.font!])
        }
    }
    
    
    func rightDropImageViewShow(_ imgName : String){
        let rightImgVw = UIImageView()
        rightImgVw.backgroundColor = UIColor.clear
        rightImgVw.frame = CGRect(x: self.frame.size.width-40,y:0,width: 30,height: self.frame.size.height)
        rightImgVw.image = UIImage(named:imgName)
        rightImgVw.contentMode = .center
        self.addSubview(rightImgVw)
    }
    
    func addRoundShadow(){
        let shadowSize : CGFloat = 5.0
           let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                      y: -shadowSize / 2,
                                                      width: self.frame.size.width + shadowSize,
                                                      height: self.frame.size.height + shadowSize))
           self.layer.masksToBounds = false
           self.layer.shadowColor = UIColor.black.cgColor
           self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
           self.layer.shadowOpacity = 0.5
     //      self.layer.shadowRadius = self.frame.size.height / 2
     //      self.layer.cornerRadius = self.frame.size.height / 2
           
           self.layer.shadowPath = shadowPath.cgPath
    }
    
}

extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var formattedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        formattedHex = formattedHex.replacingOccurrences(of: "#", with: "")

        var rgbValue: UInt64 = 0

        Scanner(string: formattedHex).scanHexInt64(&rgbValue)

        guard (2...8).contains(formattedHex.count) else {
            return nil
        }

        var red, green, blue: CGFloat

        if formattedHex.count == 2 {
            red = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
            green = CGFloat(rgbValue & 0xFF) / 255.0
            blue = 0.0
        } else if formattedHex.count == 3 {
            red = CGFloat((rgbValue & 0xF00) >> 8) / 15.0
            green = CGFloat((rgbValue & 0x0F0) >> 4) / 15.0
            blue = CGFloat(rgbValue & 0x00F) / 15.0
        } else if formattedHex.count == 6 {
            red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        } else if formattedHex.count == 8 {
            red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        } else {
            return nil
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
@available(iOS 13.0, *)
extension UIViewController {
    
    func getCurrentCountry()->Country{
        let countryCode = NSLocale.current.regionCode

        print("countryCode::: \(countryCode!)")
        
        let countryManager = CountryManager.shared
        let countryDetails = countryManager.getCountry(forCode: countryCode ?? "AE")
        return countryDetails
    }
    
    func getCountryByCode(countryCode:String)->Country{

        print("countryCode::: \(countryCode)")
        
        let countryManager = CountryManager.shared
        let countryDetails = countryManager.getCountry(forCode: countryCode)
        return countryDetails
    }
    
    func showBottumActivity(tblView:UITableView) {
        let spinner = activityIndicatorForBottum()
        tblView.tableFooterView = spinner
        tblView.tableFooterView?.isHidden = false
    }
    
    func activityIndicatorForBottum() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: UIScreen.main.bounds.size.width, height: CGFloat(44))
        return spinner
    }
    
    func getNameFromArr(arr:[String]) -> String{
           var name = String()
           
           if arr.count > 0{
               var name1 = String()
               
               for i in 0..<arr.count{
                   name1 = name1.appending("\(arr[i]), ")
               }
               
               let endIndex = name1.index(name1.endIndex, offsetBy: -2)
               name = String(name1[..<endIndex])
           }
           
           return name
       }
    
    func setNoRecordsFoundLabel(tblView:UITableView,lblText:String){
        let backView = UIView(frame: CGRect(x: 0, y: 250, width: tblView.bounds.size.width, height: 150))
        backView.backgroundColor = UIColor.clear
        
        let lbl1: UILabel = UILabel(frame: CGRect(x: 20, y: (tblView.frame.size.height / 2) - 100, width: backView.bounds.size.width - 40, height: 50))
        lbl1.numberOfLines = 0
        lbl1.text = lblText
        lbl1.textColor = UIColor.black
        lbl1.font = AppFont.regular(.subTitle)
        lbl1.textAlignment = NSTextAlignment.center
        backView.addSubview(lbl1)
        
        tblView.backgroundView = backView
    }
    
    func setNoRecordsFoundLabelOnTop(tblView:UITableView,lblText:String){
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: tblView.bounds.size.width, height: 40))
        backView.backgroundColor = UIColor.clear
        
        let lbl1: UILabel = UILabel(frame: CGRect(x: 20, y: -10, width: backView.bounds.size.width - 40, height: 30))
        lbl1.numberOfLines = 0
        lbl1.text = lblText
        lbl1.textColor = UIColor.gray
        lbl1.font = AppFont.regular(.subTitle)
        lbl1.textAlignment = NSTextAlignment.center
        backView.addSubview(lbl1)
        
        tblView.backgroundView = backView
    }
    
    func setNoRecordsFoundLabelOnCollectionView(collecView:UICollectionView,lblText:String){
       let backView = UIView(frame: CGRect(x: 0, y: 250, width: collecView.bounds.size.width, height: 150))
       backView.backgroundColor = UIColor.clear
       
       let lbl1: UILabel = UILabel(frame: CGRect(x: 20, y: (UIScreen.main.bounds.size.height / 2) - 200, width: backView.bounds.size.width - 40, height: 50))
           lbl1.numberOfLines = 0
           lbl1.text = lblText
           lbl1.textColor = UIColor.black
           lbl1.font = AppFont.regular(.subTitle)
           lbl1.textAlignment = NSTextAlignment.center
       backView.addSubview(lbl1)
       
       collecView.backgroundView = backView
    }
    
    func registerTableViewCell(_ tableView : UITableView, _ tableCell : String){
        tableView.register(UINib(nibName: tableCell, bundle: nil), forCellReuseIdentifier: tableCell)
    }
    
    func registerCollectionViewCell(_ collectionView : UICollectionView, _ collectionViewCell : String){
        collectionView.register(UINib(nibName: collectionViewCell, bundle: nil), forCellWithReuseIdentifier: collectionViewCell)
    }
    
    func hideBorder(_ view: UIView) -> Bool {
        if view.isKind(of: UIImageView.classForCoder()) && view.frame.size.height <= 1 {
            view.isHidden = true
            return true
        }
        for sub in view.subviews {
            if hideBorder(sub) {
                return true
            }
        }
        return false
    }
    
    var topbarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    var bottomBarheight: CGFloat {
        return self.tabBarController?.tabBar.frame.size.height ?? 0.0
    }
    
    func dateFromTimeInterval(_ timeInterval:String) -> String {
        let interval = timeInterval == "" ? Double(0) : Double(timeInterval)
        let date = Date(timeIntervalSince1970: interval!)
        let formatter = DateFormatter()
        //formatter.dateFormat = Constants.shared.dateFormat
        let strDate = ""//APIManager.getVal(formatter.string(from: date)) as! String
        return strDate
    }
    
    func RootViewControllerWithNav(_ RootViewController: UIViewController){
        let slideInFromLeftTransition = CATransition()
        slideInFromLeftTransition.duration = 1
        slideInFromLeftTransition.type = .fade
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromBottom;
        self.view.window?.layer.add(slideInFromLeftTransition, forKey: kCATransition)
        self.view.window?.rootViewController = UINavigationController (rootViewController: RootViewController)
    }
    
    func pushViewController(_ PushController: UIViewController){
        let DetailVC = PushController
        self.navigationController?.pushViewController(DetailVC, animated: true)
    }
    
    func popViewController(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func presentViewController(_ PresentController: UIViewController){
        let DetailVC = PresentController
        let navctrl = UINavigationController(rootViewController: DetailVC)
        self.present(navctrl, animated: true, completion: nil)
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func RootViewController(_ RootViewController: UIViewController){
        let slideInFromLeftTransition = CATransition()
        slideInFromLeftTransition.duration = 1
        slideInFromLeftTransition.type = .fade
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromBottom;
        self.view.window?.layer.add(slideInFromLeftTransition, forKey: kCATransition)
        self.view.window?.rootViewController = RootViewController
    }
    
    func showViewWithFadeIn(_ View: UIView){
       // self.pleaseWait()
        let animationDuration = 0.35
        View.transform = View.transform.scaledBy(x: 0.001, y: 0.001)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            View.transform = CGAffineTransform.identity
            View.isHidden = false
            //self.clearAllNotice()
        })
    }
    
    func hideViewWithFadeIn(_ View: UIView){
        let animationDuration = 0.35
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            View.transform = View.transform.scaledBy(x: 0.001, y: 0.001)
        }, completion: { (completion) -> Void in
            View.isHidden = true
        })
    }
    
    func resizeImageSize(_ image:UIImage) -> UIImage {
        let actualHeight = Int(image.size.height);
        let actualWidth = Int(image.size.width);
        let compressionQuality:CGFloat = 0.3
        let newsizeWidth = CGFloat( actualWidth ) * CGFloat(compressionQuality)
        let newsizeHeight = CGFloat( actualHeight ) * CGFloat(compressionQuality)
        let newSize = CGSize(width: newsizeWidth , height: newsizeHeight);
        // Scale the original image to match the new size.
        UIGraphicsBeginImageContext(newSize);
        image.draw(in: CGRect(x: 0, y: 0 , width: newSize.width , height: newSize.height))
        let compressedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return compressedImage!
    }
    
  
    
    func attributedLabel(title:String,subtitle:String)-> NSMutableAttributedString{
        let Attributes = [NSAttributedString.Key.foregroundColor: UIColor.appBase, NSAttributedString.Key.font:AppFont.regular(.subTitle)]
        
        let attrString1 = NSAttributedString(string: title+" : ", attributes: Attributes)
        let attrString2 = NSAttributedString(string: subtitle, attributes: Attributes)
        
        let combin = NSMutableAttributedString()
        combin.append(attrString1)
        combin.append(attrString2)
        return combin
    }
    
       func saveImage(image: UIImage,name:String) -> Bool {
           guard let data = image.jpegData(compressionQuality: 0.4) else {
               return false
           }
           guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
               return false
           }
           do {
               try data.write(to: directory.appendingPathComponent(name)!)
               return true
           } catch {
               print(error.localizedDescription)
               return false
           }
       }
       
       func getSavedImage(named: String) -> UIImage? {
           if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
               return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
           }
           return nil
       }
}

extension UIButton {
    func setImageFromURL(_ urlString: String, placeHolder: UIImage?) {
        guard let url = URL(string: urlString) else {
            self.setImage(placeHolder, for: .normal)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self?.setImage(placeHolder, for: .normal)
                }
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.setImage(image, for: .normal)
            }
        }.resume()
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIImageView {
    func adjustBrightness(factor: CGFloat) {
        guard let currentImage = self.image else { return }
        
        let context = CIContext(options: nil)
        let ciImage = CIImage(cgImage: currentImage.cgImage!)
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(factor, forKey: kCIInputBrightnessKey)
        
        if let outputImage = filter?.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                self.image = UIImage(cgImage: cgimg)
            }
        }
    }
}


@IBDesignable
class LinearGradientView: UIView {
    
    private var gradientLayer: CAGradientLayer!
    
    // MARK: - Inspectable Properties
    
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            updateGradientColors()
        }
    }
    
    @IBInspectable var endColor: UIColor = .black {
        didSet {
            updateGradientColors()
        }
    }
    
    @IBInspectable var verticalGradient: Bool = true {
        didSet {
            updateGradientColors()
        }
    }
    
    // MARK: - Initialization and Private Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradientLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        updateGradientColors()
    }
    
    private func setupGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradientColors()
    }
    
    private func updateGradientColors() {

        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        if verticalGradient {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
    }
    
    
}

class UINavigationBarGradientView: UIView {

    enum Point {
        case topRight, topLeft
        case bottomRight, bottomLeft
        case custom(point: CGPoint)

        var point: CGPoint {
            switch self {
                case .topRight: return CGPoint(x: 1, y: 0)
                case .topLeft: return CGPoint(x: 0, y: 0)
                case .bottomRight: return CGPoint(x: 1, y: 1)
                case .bottomLeft: return CGPoint(x: 0, y: 1)
                case .custom(let point): return point
            }
        }
    }

    private weak var gradientLayer: CAGradientLayer!

    convenience init(colors: [UIColor], startPoint: Point = .topLeft,
                     endPoint: Point = .bottomLeft, locations: [NSNumber] = [0, 1]) {
        self.init(frame: .zero)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
        set(colors: colors, startPoint: startPoint, endPoint: endPoint, locations: locations)
        backgroundColor = .clear
    }

    func set(colors: [UIColor], startPoint: Point = .topLeft,
             endPoint: Point = .bottomLeft, locations: [NSNumber] = [0, 1]) {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint.point
        gradientLayer.endPoint = endPoint.point
        gradientLayer.locations = locations
    }

    func setupConstraints() {
        guard let parentView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        parentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        parentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let gradientLayer = gradientLayer else { return }
        gradientLayer.frame = frame
        superview?.addSubview(self)
    }
}

extension UINavigationBar {
    func setGradientBackground(colors: [UIColor],
                               startPoint: UINavigationBarGradientView.Point = .topLeft,
                               endPoint: UINavigationBarGradientView.Point = .bottomLeft,
                               locations: [NSNumber] = [0, 1]) {
        guard let backgroundView = value(forKey: "backgroundView") as? UIView else { return }
        guard let gradientView = backgroundView.subviews.first(where: { $0 is UINavigationBarGradientView }) as? UINavigationBarGradientView else {
            let gradientView = UINavigationBarGradientView(colors: colors, startPoint: startPoint,
                                                           endPoint: endPoint, locations: locations)
            backgroundView.addSubview(gradientView)
            gradientView.setupConstraints()
            return
        }
        gradientView.set(colors: colors, startPoint: startPoint, endPoint: endPoint, locations: locations)
    }
}

extension UIView {
    
    func addGradientToView(colors: [UIColor]) {
        // Create a CAGradientLayer instance
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        
        // Convert UIColor array to CGColor array
        let cgColors = colors.map { $0.cgColor }
        
        // Set the colors for the gradient
        gradientLayer.colors = cgColors
       // gradientLayer.contentsGravity = .resize

        // You can customize the gradient direction if needed
         gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
         gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Add the gradient layer to the view's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addGradientToViewTopToBottom(colors: [UIColor]) {
        // Create a CAGradientLayer instance
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        
        // Convert UIColor array to CGColor array
        let cgColors = colors.map { $0.cgColor }
        
        // Set the colors for the gradient
        gradientLayer.colors = cgColors
       // gradientLayer.contentsGravity = .resize

        // You can customize the gradient direction if needed
//         gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//         gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Add the gradient layer to the view's layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    
    func roundSpecificCorners(corners: UIRectCorner, radius: CGFloat) {
          let path = UIBezierPath(
            roundedRect: self.bounds,
              byRoundingCorners: corners,
              cornerRadii: CGSize(width: radius, height: radius)
          )
          
          let maskLayer = CAShapeLayer()
          maskLayer.path = path.cgPath
          self.layer.mask = maskLayer
      }
    
     func dropShadow(_ shadowColor : UIColor) {
         //  self.layer.cornerRadius = 2
        //   self.layer.masksToBounds = true
           
           self.layer.masksToBounds = false
           self.layer.shadowColor = shadowColor.cgColor
           self.layer.shadowOffset = CGSize(width: 0, height: 0)
           self.layer.shadowOpacity = 0.3
           self.layer.shadowRadius = 5.0
       }
       
       func removeDropedShadow() {
           self.layer.cornerRadius = 0
        //   self.layer.masksToBounds = true
           
           self.layer.masksToBounds = false
           self.layer.shadowColor = UIColor.clear.cgColor
           self.layer.shadowOffset = CGSize(width: 0, height: 0)
           self.layer.shadowOpacity = 1
           self.layer.shadowRadius = 1.0
       }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow(shadowRadius: 4.0)
            }
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.darkGray.cgColor,
                   shadowOffset: CGSize = CGSize(width: 0, height: 0),
                   shadowOpacity: Float = 0.3,
                   shadowRadius: CGFloat) {
        
        layer.cornerRadius = shadowRadius
        layer.masksToBounds = true
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = 3.0
    }
    
    @IBInspectable var halfShadowRadius: Bool {
        get {
            return true
        }
        set {
            addShadow(shadowRadius: self.frame.size.height/2)
        }
    }
    
}

extension UILabel{

    func setLabel(text:String,font_size:CGFloat,text_color:UIColor,text_alignment:NSTextAlignment){
        self.textColor = text_color
        self.text = text
        self.textAlignment = text_alignment
        self.backgroundColor = UIColor.clear
        self.font = UIFont.systemFont(ofSize: font_size)
    }
    
    func getStrokeString(text:String) {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        self.attributedText = attributeString
    }
}

extension Int {
    func dateFromMilliseconds() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self)/1000)
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ size:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension Date
{
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func dateToDate( dateFormat format  : String ) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateStr = dateFormatter.string(from: self)
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = format
        
        let date = dateFormatter.date(from: dateStr)
        return date!
    }
}

extension String
{
    func dateStringToString() -> String{
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Use the same format as the date string
    
            if let date = dateFormatter1.date(from: self) {
                print("Parsed Date: \(date)")
    
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MM/dd/yyyy hh:mm a" // Define your desired date format
    
                let dateString2 = dateFormatter2.string(from: date)
                print("New Formatted Date: \(dateString2)")
                return dateString2
    
            } else {
                print("Unable to parse date")
            }
        
         return ""
    }
    
    func dateStringToTimeString() -> String{
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Use the same format as the date string
    
            if let date = dateFormatter1.date(from: self) {
                print("Parsed Date: \(date)")
    
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "hh:mm a" // Define your desired date format
    
                let dateString2 = dateFormatter2.string(from: date)
                print("New Formatted Date: \(dateString2)")
                return dateString2
    
            } else {
                print("Unable to parse date")
            }
        
         return ""
    }
    
    func dateStringToDateString() -> String{
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Use the same format as the date string
    
            if let date = dateFormatter1.date(from: self) {
                print("Parsed Date: \(date)")
    
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MM/dd/yyyy" // Define your desired date format
    
                let dateString2 = dateFormatter2.string(from: date)
                print("New Formatted Date: \(dateString2)")
                return dateString2
    
            } else {
                print("Unable to parse date")
            }
        
         return ""
    }
    
    func dateStringToDateTimeString() -> String{
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // Use the same format as the date string
    
            if let date = dateFormatter1.date(from: self) {
                print("Parsed Date: \(date)")
    
                let dateFormatter2 = DateFormatter()
                dateFormatter2.dateFormat = "MM/dd/yyyy hh:mm a" // Define your desired date format
    
                let dateString2 = dateFormatter2.string(from: date)
                print("New Formatted Date: \(dateString2)")
                return dateString2
    
            } else {
                print("Unable to parse date")
            }
        
         return ""
    }
    
    func setStrikethroughStyle() -> NSAttributedString{
                
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()

        return label.frame.height
    }
    
    func toDate( dateFormat format  : String ) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        if let date = formatter.date(from: self) {
            return date
        }
        else{
            return Date()
        }
    }
    
    func size(OfFont font: UIFont) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
    }
    

    var htmlToAttributedString: NSAttributedString? {
            guard let data = data(using: .utf8, allowLossyConversion: false) else { return NSAttributedString() }
            do {
                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                return NSAttributedString()
            }
        }
    
    // font-size: 13px;
    func loadHTMLText()-> NSAttributedString {
       
       let html = "<html><head><style>body{font-family:'Montserrat-Regular';line-height: 16px;}</style><title></title></head><body>" as NSMutableString
        
           html.append(self)
           html.append(" </body></html>")
        
     //   let font = "<font face='HiraMaruProN-W4' size='3' color= 'red'>%@"
      //  let n_html = String(format: font, html)
        
        return (html as String).htmlToAttributedString!
    }
    
//    var htmlToString: NSAttributedString {
//        return htmlToAttributedString
//    }
}


//extension UIViewController {
//
//    func getBadgeCount() -> Int{
//        let badgeCount = Utilities.shared.UDValue(.badgeCount)
//        if badgeCount.count != 0{
//            return Int(badgeCount)!
//        }
//
//        return 0
//    }
//
//    func setBadgeCount(newBadge:Int){
//        let badgeCount = Utilities.shared.UDValue(.badgeCount)
//        if badgeCount.count != 0{
//            let newBadgeL = Int(badgeCount)! + newBadge
//            Utilities.shared.UDSave("\(newBadgeL)", forKey: .badgeCount)
//        }
//        else{
//            let newBadgeL = newBadge
//            Utilities.shared.UDSave("\(newBadgeL)", forKey: .badgeCount)
//        }
//
//    }
//}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIViewController{
    
    func concatTwoStrings(firstString:String,secondString:String)-> NSMutableAttributedString{
        let attributedString = NSMutableAttributedString()
                
        let firstAttributedString = NSAttributedString(string: firstString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black,NSAttributedString.Key.font: AppFont.boldFont(boldFontWithSize: 13)])
                attributedString.append(firstAttributedString)
                
        let spaceAttributedString = NSAttributedString(string: " ")
            attributedString.append(spaceAttributedString)
                
                // Append the second string with its color
        let secondAttributedString = NSAttributedString(string: secondString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.appGray,NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 13)])
                attributedString.append(secondAttributedString)
                
                // Apply the attributed string to your label
           return attributedString
    }
    
    
    func saveImageToDocumentDirectory(image: UIImage,imageName:String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = imageName // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            let image    = UIImage(contentsOfFile: imageURL.path)
            if image != nil{
                return image!
            }
        }
        return UIImage.init(named: "5")!
    }
    
    func getSavedVideo(songURL:String) -> String {
        
        if let audioUrl = URL(string: songURL) {
            
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            
            return "\(destinationUrl)"
    
        }
        else{
            return ""
        }
        
    }
}

extension Date {

    func timeAgoSinceDate() -> String {

       // From Time
       let fromDate = self

       // To Time
       let toDate = Date()

       // Estimation
       // Year
       if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "y" : "\(interval)" + " " + "y"
       }

       // Month
       if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
           return interval == 1 ? "\(interval)" + " " + "m" : "\(interval)" + " " + "m"
       }
        
       // Day
       if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
           return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
       }

       // Hours
       if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
           return interval == 1 ? "\(interval)" + " " + "h" : "\(interval)" + " " + "h"
       }

       // Minute
       if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
           return interval == 1 ? "\(interval)" + " " + "min" : "\(interval)" + " " + "min"
       }

       return "Just Now"
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: AppFont.regular(.subTitle)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func bold_color(_ text: String) -> NSMutableAttributedString {
           let attrs: [NSAttributedString.Key: Any] = [.font: AppFont.regular(.subTitle),.foregroundColor: UIColor.appBase]
           let boldString = NSMutableAttributedString(string:text, attributes: attrs)
           append(boldString)
           
           return self
       }
    
    @discardableResult func bold__black_color(_ text: String) -> NSMutableAttributedString {
              let attrs: [NSAttributedString.Key: Any] = [.font: AppFont.regular(.subTitle),.foregroundColor: UIColor.black]
              let boldString = NSMutableAttributedString(string:text, attributes: attrs)
              append(boldString)
              
              return self
          }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: AppFont.regular(.subTitle)]
        let normal = NSMutableAttributedString(string:text, attributes: attrs)
        append(normal)
        
        return self
    }
}

extension UILabel {

    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        let readMoreText: String = trailingText + moreText

        let lengthForVisibleString: Int = self.vissibleTextLength
        let mutableString: String = self.text!
        let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.count)! - lengthForVisibleString)), with: "")
        let readMoreLength: Int = (readMoreText.count)
        let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
        let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font!])
        let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: moreTextColor])
        answerAttributed.append(readMoreAttributed)
        self.attributedText = answerAttributed
    }

    var vissibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [NSAttributedString.Key : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)

        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.count
    }
}


extension Array
{
   func filterDuplicate<T:Hashable>(_ keyValue:(Element)->T) -> [Element]
   {
      var uniqueKeys = Set<T>()
      return filter{uniqueKeys.insert(keyValue($0)).inserted}
   }

   func filterDuplicate<T>(_ keyValue:(Element)->T) -> [Element]
   {
      return filterDuplicate{"\(keyValue($0))"}
   }
}

extension Int {
    func withCommasEnter() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}

extension String {
    func withCommas() -> String {
        
        if self.count > 0{
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            
        //    numberFormatter.maximumFractionDigits = 0;
            return numberFormatter.string(from: NSNumber(value:Double(self)!))!
        }
         return self
    }
}

extension UIImageView{
    func mirrorImage(){
//        if UIApplication.isRTL() {
//            self.layer.setAffineTransform(CGAffineTransform(scaleX: -1, y: 1))
//        }
    }
}

extension UIViewController{
    func presentOnRoot(`with` viewController : UIViewController){
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(navigationController, animated: false, completion: nil)
    }
    
    func presentOnViewController(`with` viewController : UIViewController){
        viewController.modalPresentationStyle = .overCurrentContext
        self.present(viewController, animated: false, completion: nil)
    }
}
	
