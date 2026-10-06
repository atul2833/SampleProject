//
//  RentalPropertiesVC.swift
//  TAGCreditMerchant
//
//  Created by somendra on 18/07/24.
//

import UIKit

class RentalPropertiesVC: BaseNavigationController {

    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!

    private var viewModel: RentalViewModel
    let currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    init(viewModel: RentalViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit{
        Log.info("====== \(self) ======")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblView.delegate = self
        
        self.stateObserver()
        self.navigationItem.title = "Rental Properties"
        
        tblView.register(UINib(nibName: "RentalPropertiesTableCell", bundle: nil), forCellReuseIdentifier: "RentalPropertiesTableCell")
        
        
        searchBar.delegate = self
        searchBar.searchTextField.placeHolderColr = UIColor.appGray
        searchBar.searchTextField.font = AppFont.regularFont(regularFontWithSize: 14)
        
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)

      //  segmentControl.tintColor = UIColor.red
       // segmentControl.backgroundColor = UIColor.blue
        
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 14)], for: .normal)

               // Change text color and the font of the selected segment
        
        
        segmentControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: AppFont.regularFont(regularFontWithSize: 14)
        ], for: .selected)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getPropertyData(page: 1, clearData: true, searchText: "")
        
        let rightBtn = ResponsiveButton(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40)
        )
        
        rightBtn.setImage(
            UIImage(named: "rentHistoryIcon"),
            for: .normal
        )
        
        rightBtn.addTarget(
            self,
            action: #selector(rightButtonAction(_:)),
            for: .touchUpInside
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: rightBtn
        )
    }
    
    @objc private func rightButtonAction(_ sender: ResponsiveButton) {
        let vc = RentalHistoryVC(viewModel: RentalViewModel())
        self.navigationController?.pushViewController(vc, animated: true)
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
                    self?.loadTableView()
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
    
    func getPropertyData(page:Int,clearData:Bool,searchText:String){
        
        if clearData{
            viewModel.clearRenatalData()
        }

        var model = viewModel.paginationParams
            model.page = page
            model.type = segmentControl.selectedSegmentIndex == 0 ? "all" : "myRented"
            model.search = searchText
        viewModel.paginationParams = model
        
        self.viewModel.getPropertyList()

    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Selected segment index: \(sender.selectedSegmentIndex)")
        
        searchBar.text = ""
        getPropertyData(page: 1, clearData: true, searchText: "")
        
      
    }
    
    @IBAction func segmentControllerClikced(_ sender: Any) {
        segmentControl.setTitleTextAttributes(
                [.foregroundColor: UIColor.black],
                for: .normal
            )

            segmentControl.setTitleTextAttributes(
                [.foregroundColor: UIColor.white],
                for: .selected
            )
    }
    @IBAction func rentalBtnPress(_ sender: UIButton) {
//        let vc = CreateRentalPropertiesVC(viewModel: RentalViewModel(), viewModelRegister: RegisterViewModel(), propertyId: nil)
//        self.navigationController?.pushViewController(vc, animated: true)
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
        } else {
            tblView.reloadData()
        }
        
    }
}

extension RentalPropertiesVC: UITableViewDelegate,UITableViewDataSource {
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: "No block"
            )
        } else {
            self.tblView.restore()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.getNumberOfRows()
        self.showHideEmptyState(isShow: rows == 0)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "RentalPropertiesTableCell", for: indexPath) as! RentalPropertiesTableCell
        
        let item = viewModel.getNumberOfItem(At: indexPath)
        cell.imgView.sd_setImage(with: item?.propertyImageURL)
        cell.lblTitle.text = item?.title
        cell.lblDuration.text = "/\(item?.rentType ?? "")"
        cell.lblDescription.text = item?.description
        cell.lblPrice.text = "\(currency ?? "")\(item?.price ?? "")"
        cell.selectionStyle = .default
            return cell
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = PropertyDetailsVC(viewModel: RentalViewModel(), propertyId: item?.propertyId ?? "",propertyStatus: item?.propertyStatus ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension RentalPropertiesVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            getPropertyData(page: viewModel.paginationParams.page, clearData: false, searchText: searchBar.text ?? "")
        }
    }
}

extension RentalPropertiesVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getPropertyData(page: 1, clearData: true, searchText: searchText)
    }
}
