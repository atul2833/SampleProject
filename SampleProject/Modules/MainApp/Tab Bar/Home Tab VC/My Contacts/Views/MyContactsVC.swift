//
//  MyContactsVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.

import UIKit
import ContactsUI


class MyContactsVC: BaseNavigationController,UISearchBarDelegate{
    
    @IBOutlet weak var tblView:UITableView!

    @IBOutlet weak var srchBar:UISearchBar!
    @IBOutlet weak var recentsView:UIView!
    @IBOutlet weak var topTblView:NSLayoutConstraint!

    var recentArr:Array<UserList> = []
    var myContactsArr:Array<UserList> = []

    var coming_from = String()
    
    var currentPage = 1
    var isPagingAllowed = true

    var num_of_pages = 1
    var total_ques = String()
    var colors = ["BCEEFD","DEE7FF","D8F2E9","FFE5DB","BCDFFD","FFDDE3","ECF2D8","DBF9FF"]
    var contactArr = [ContactItem]()
    
    private let loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView(style: .medium)
        loaderView.hidesWhenStopped = true
        return loaderView
    }()

    lazy var contactsAll: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()

    private var viewModel: MyContactsViewModel

    init(viewModel: MyContactsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()

        self.navigationItem.title = "Contacts"
        stateObserver()
        
        tblView.register(UINib(nibName: "ContactsTblViewCell", bundle: nil), forCellReuseIdentifier: "ContactsTblViewCell")

        tblView.tableFooterView = UIView()
        
        print(contactsAll)
        
        DispatchQueue.main.async {
            self.setPaginationData(searchText: "", isLoading: true)
        }
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
                    self?.showAlert(message:message)
                    break
                case .listFetched:
                    ProgressHudWrapper.dismiss()
                    self?.loadTableView()
                    self?.showLoaderView(isShow: false)
                    break
                case .error(let message):
                    ProgressHudWrapper.dismiss()
                    Log.error(message)
                    self?.view.makeToast(message, position: .bottom)
                case .logout:
                    ProgressHudWrapper.dismiss()
                    let tabBar = self?.tabBarController as? HomeTabBarController
                    tabBar?.logout()
                default:
                    ProgressHudWrapper.dismiss()
                    break
                }
            }
            .store(in: &self.viewModel.cancellable)
    }
    
    private func showLoaderView(isShow: Bool) {
        loaderView.frame = CGRect(x: 0, y: 0, width: tblView.bounds.width, height: 50) // Adjust height as needed
        loaderView.hidesWhenStopped = true
        if isShow {
            tblView.tableFooterView = loaderView
            self.loaderView.startAnimating()
            
        }else {
            self.loaderView.stopAnimating()
            tblView.tableFooterView = nil
        }
    }
    
     func checkInputTypeIsNumber(input: String)->Bool {
         // Attempt to convert the input to a number (integer or floating-point)
         if let numValue = Double(input) {
             // If the conversion succeeds, it's a number
            return true
         }
         return false
     }
     
     func removeSpaceAndDashBetweenNumber(input: String)->String {
         let resultString = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
         return resultString
     }
     
     func setPaginationData(searchText: String, isLoading: Bool) {
         self.myContactsArr.removeAll()  // Clear existing data

         // Sort contacts alphabetically based on givenName and familyName
         let sortedContacts = contactsAll.sorted { (contact1, contact2) -> Bool in
             let fullName1 = "\(contact1.givenName) \(contact1.familyName)"
             let fullName2 = "\(contact2.givenName) \(contact2.familyName)"
             return fullName1.localizedCaseInsensitiveCompare(fullName2) == .orderedAscending
         }

         let list = viewModel.paginationParams  // Get pagination parameters

         // Calculate total pages based on the total number of contacts and the page limit
         viewModel.paginationParams.totalPage = (sortedContacts.count / list.limit) + 1

         let from = (list.page - 1) * list.limit  // Calculate 'from' index for pagination
         let to = ((list.page) * list.limit) - 1  // Calculate 'to' index for pagination

         print("Total Contacts: \(sortedContacts.count), From: \(from), To: \(to)")

         // Check if there is a search query
         if !searchText.isEmpty {
             // Filter contacts based on the search criteria
             let searchedContacts = sortedContacts.filter { contact in
                 let fullName = "\(contact.givenName) \(contact.familyName)"
                 return fullName.localizedCaseInsensitiveContains(searchText)
             }

             DispatchQueue.main.async {
                 print("Searched Contacts Count: \(searchedContacts.count)")
                 // Check if the filtered contacts array contains the required range
                 if searchedContacts.indices.contains(from) {
                     // Adjust 'to' index to stay within array bounds
                     let adjustedTo = min(to, searchedContacts.count - 1)
                     let selectedContacts = Array(searchedContacts[from...adjustedTo])
                     print("Selected Searched Contacts: \(selectedContacts)")
                     // Call filterData with the filtered contacts
                     self.filterData(searchKey: searchText, selectedContacts: selectedContacts, isLoading: isLoading)
                 } else {
                     print("No data found in searched contacts")
                     // Load table view with no data if the required range is not within the filtered contacts
                     self.loadTableView()
                 }
             }
         } else {
             // No search query, use all contacts for pagination
             DispatchQueue.main.async {
                 print("Total Contacts Count: \(sortedContacts.count)")
                 if sortedContacts.indices.contains(from) {
                     let adjustedTo = min(to, sortedContacts.count - 1)  // Adjust 'to' index to stay within array bounds
                     let selectedContacts = Array(sortedContacts[from...adjustedTo])
                     print("Selected Contacts: \(selectedContacts)")
                     // Call filterData with the paginated contacts
                     self.filterData(searchKey: searchText, selectedContacts: selectedContacts, isLoading: isLoading)
                 } else {
                     print("No data found in total contacts")
                     // Load table view with no data if the required range is not within all contacts
                     self.loadTableView()
                 }
             }
         }
     }

     func filterData(searchKey: String, selectedContacts: [CNContact], isLoading: Bool) {
         var dataArr = [[String: Any]]()
         
         for contact in selectedContacts {
             var dict = [String: Any]()
             dict["name"] = contact.givenName + " " + contact.familyName

             let phoneArr = contact.phoneNumbers.compactMap {
                 ($0.value).value(forKey: "digits") as? String
             }

             dict["phone"] = phoneArr
             dataArr.append(dict)
         }
         
         DispatchQueue.main.async {
             print("Filtered Data: \(dataArr)")
             
             self.viewModel.getInvitationContacts(page: self.viewModel.paginationParams.page, list: dataArr, isLoading: isLoading)
         }
     }
    
    private func loadTableView() {
        // >2 as paginationParams.page is updated before this method is called
        if viewModel.paginationParams.page > 2 {
            let currentCount = tblView.numberOfRows(inSection: 0)
            let newCount = viewModel.getNumberOfRows()
            if newCount > currentCount {
                let indexPaths = (currentCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tblView.beginUpdates()
                tblView.insertRows(at: indexPaths, with: .automatic)
                tblView.endUpdates()
            }
        } 
        else {
            tblView.reloadData()
        }
    }
    
    @IBAction func inviteBtnAction(_ sender:ResponsiveButton){
        
        let selectedUserIds = viewModel.getSelectedUsers()

        if selectedUserIds?.count == 0{
            self.view.makeToast("Please select atleast 1 friend!")
        }
        else{
            viewModel.sendInvitation(selectedUserIds: selectedUserIds)
        }
    }
    
    func showAlert(message:String){
        let vc = CustomAlertInfoView()
            vc.comingTitle = "Successfully sent"
            vc.comingDescription = message
            vc.comingImage = "Group 71526"
            vc.alertConfirm = self
        self.presentOnViewController(with: vc)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchText \(searchText)")
                
        viewModel.clearContactsData()
        viewModel.paginationParams.page = 1

        DispatchQueue.main.async {
            self.setPaginationData(searchText: searchText, isLoading: false)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchText \(searchBar.text!)")
        self.view.endEditing(true)

        viewModel.clearContactsData()
        viewModel.paginationParams.page = 1

        DispatchQueue.main.async {
            self.contactArr.removeAll()
            self.setPaginationData(searchText: searchBar.text ?? "", isLoading: false)
        }
    }
    
    
    @objc func checkBoxBtnPressed(sender:UIButton) {
            // Handle button tap event
        
        if contactArr[sender.tag].isSelected == false {
            contactArr[sender.tag].isSelected = true
        }
        else{
            contactArr[sender.tag].isSelected = false
        }
        
        tblView.reloadData()
        
        print("Button tapped!")
    }
}

extension MyContactsVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: ""
            )
        } else {
            self.tblView.restore()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)

        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTblViewCell", for: indexPath) as! ContactsTblViewCell
        
                
            let item = viewModel.getNumberOfItem(At: indexPath)
            
            cell.title_lbl.text = item?.name
            cell.desc_lbl.text = item?.phone
               // cell.imgView.sd_setImage(with: URL(string: list.profile_image ?? ""))
            
            cell.imgLabel.isHidden = false
            cell.imgView.isHidden = true
            cell.imgLabel.backgroundColor = UIColor(hex: colors[indexPath.row % 8])
           // cell.inviteBtn.isHidden = list.user_id != "0"
            if item?.userId == "0"{
                cell.inviteView.isHidden = false
                cell.checkBoxBtn.isHidden = true
              
            }
            else if item?.isAlreadyMember ?? false{
                cell.inviteView.isHidden = true
                cell.checkBoxBtn.isHidden = true
            }
            else{
                cell.inviteView.isHidden = true
                cell.checkBoxBtn.isHidden = false
               
                if item?.isSelected == true {
                    cell.checkBoxBtn.setImage(UIImage(named: "CheckSelected"), for: .normal)
                    print("intrue")
                    
                }else{
                    cell.checkBoxBtn.setImage(UIImage(named: "CheckUnselected"), for: .normal)
                    print("infalse")
              
                }
            }
            
//            cell.checkBoxBtn.tag = indexPath.row
//            cell.checkBoxBtn.addTarget(self, action: #selector(checkBoxBtnPressed ), for: .touchUpInside)

                var initials = String()
                
        let nameArr = item?.name?.components(separatedBy: " ")
                
                if nameArr?.count == 1{
                    if let firstNameFirstChar = nameArr?[0].first {
                        initials.append(firstNameFirstChar)
                    }
                }
                else{
                    if let firstNameFirstChar = nameArr?[0].first {
                        initials.append(firstNameFirstChar)
                    }
                    
                    if let lastNameFirstChar = nameArr?[1].first {
                        initials.append(lastNameFirstChar)
                    }
                }
                
                cell.imgLabel.text = initials

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let list = contactArr[indexPath.row]
//        self.navigationController?.popViewController(animated: true)
        
//        if contactArr[indexPath.row].isSelected == false {
//            contactArr[indexPath.row].isSelected = true
//        }else{
//            contactArr[indexPath.row].isSelected = false
//        }
        
        viewModel.setSelectedValue(At: indexPath)
        
        DispatchQueue.main.async {
            self.tblView.reloadData()
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == tblView{
            if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
                
                if isPagingAllowed{
                    
                     if currentPage <= num_of_pages{
                         self.isPagingAllowed = false
                         currentPage += 1
                      // if currentPage <= Int(totalPages)!{
                         
                        // if num_of_pages != 1{
                             
                         if currentPage <= num_of_pages{
                             showBottumActivity(tblView: self.tblView)
                         }
                        // }
                     }
                     else{
                         self.tblView.tableFooterView = UIView()
                     }

                }
                else{
                    self.tblView.tableFooterView = UIView()
                }
            }
        }
    }
    
    func inviteApp(){
        let sharedObjects:[AnyObject] = ["Comera Pay" as AnyObject]
     
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MyContactsVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            self.setPaginationData(searchText: self.srchBar.text ?? "", isLoading: false)
        }
    }
}


extension MyContactsVC: AlertInfoDelegate{
    func alertInfoAction(_ status: String) {
        
        let vc = BlockDetailsVC(viewModel: BlockDetailViewModel(blockId: viewModel.getBlockId() ?? ""), contributionViewModel: ContributionViewModel(blockId: viewModel.getBlockId() ?? ""))
            //    vc.transactionId = cellVM.transactionId
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}


class UserList:NSObject {
    
    var addr_line1 : String?
    var addr_line2 : String?
    var city : String?
    var country : String?
    var email : String?
    var name : String?
    
    var phone : String?
    var qrcode : String?
    var state : String?
    var user_id : String?
    var zip : String?
    var image:String?
    var profile_image:String?
    
    override init(){
        debugPrint("init App")
        super.init()
    }
    
}

class TransactionList:NSObject {
    
    var payment_mode:String?
    var payment_mode_name:String?
    var received_amount:String?
    var transaction_fees:String?

    var trans_id : String?
    var trans_amount : String?
    var trans_type : String?
    var trans_to : String?
    var trans_from : String?
    var sender : String?
    
    var sender_id : String?
    var receiver : String?
    var receiver_id : String?
    var trans_status : String?
    var refrence_id : String?
    var trans_date:String?
    
    var sender_phone:String?
    var receiver_phone:String?
    
    var trans_medium:String?
    var trans_medium_id:String?
    var trans_medium_number:String?
    var trans_date2 :String?
    
    override init(){
        debugPrint("init App")
        super.init()
    }
    
    
}

class MobileListModal:NSObject {
    
     var card_id : String?
     var card_image : String?
    
    override init() {
        super.init()
    }
    
     
}

class NearestListModal:NSObject {
    
     var name : String?
     var phone : String?
     var user_id : String?
     var business_image : String?

    override init() {
        super.init()
    }
    
      
}

class RechargeOptionList:NSObject {
    
    var card_id : String?
    var card_description : String?
    var card_value : String?
    var card_name : String?
    var real_value:String?
    var currency:String?

   override init() {
       super.init()
   }
   
    
}

class LocationDataModal : NSObject{
 
    var user_id : String?
    var name : String?
    var image : String?
    var phone : String?
    var latitude : String?
    var longitude : String?
    var user_type : String?
    
    var distance = 0.0
    
    override init() {
        
    }
 
    
}

class NotificationsList:NSObject {
    
    var id : String?
    var user_id : String?
    var title : String?
    var body : String?
    var date : String?
    var is_seen : String?
    
    override init(){
        debugPrint("init App")
        super.init()
    }
    
    
}

struct ProfileMenu: Identifiable {
    var id = UUID()
    
    let title: String
    let description : String
    let image: String
    //let slug: Route
    let bottomLine:String
}

struct ContactItem: Identifiable {
    var id = UUID()
    var name = String()
    var phoneNumber = String()
    var fullPhoneNumberStr = String()
    var phoneNumberStr = String()
    var countryCode = String()
    var isSelected = Bool()
}
