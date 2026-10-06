//
//  AllBlockNewVC.swift
//  TagCredit
//
//  Created by Niketan Sharma on 08/03/24.
//

import UIKit

class AllBlockVC: BaseNavigationController {
    
        //    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var blockTblView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!

    var currentPage = 1
    var isPagingAllowed = true
    
    var isFetchingData = false
    
    var isDateViewHidden = true
    var selectedIndexMonth = -1
    var filterType = "Month"
    
    private var viewModel: BlockViewModel
    private var currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String

    init(viewModel: BlockViewModel) {
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
        self.navigationItem.title = "All Blocks"
        
        initView()
        stateObserver()
        searchBar.delegate = self
        searchBar.searchTextField.placeHolderColr = UIColor.appGray
        searchBar.searchTextField.font = AppFont.regularFont(regularFontWithSize: 14)
        
        getBlockData(page: 1, clearData: true, searchText: "")
        
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)

      //  segmentControl.tintColor = UIColor.red
       // segmentControl.backgroundColor = UIColor.blue
        
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 14)], for: .normal)

               // Change text color and the font of the selected segment
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 14)], for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getBlockData(page:Int,clearData:Bool,searchText:String){
        
        if clearData{
            viewModel.clearBlockData()
        }
        
        var model = viewModel.paginationParams
            model.page = page
            model.type = segmentControl.selectedSegmentIndex == 0 ? "popularBlocks" : "swapPopularBlocks"
            model.search = searchText
        viewModel.paginationParams = model

        self.viewModel.getBlockList()
    }
    
    func initView(){
        
        blockTblView.register(UINib(nibName: "BlockTblViewCell", bundle: nil), forCellReuseIdentifier: "BlockTblViewCell")
            //        blockTblView.tableFooterView = UIView()
    }
    
    private func stateObserver() {
        self.viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .blockListFetched:
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
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Selected segment index: \(sender.selectedSegmentIndex)")
        
        searchBar.text = ""
        getBlockData(page: 1, clearData: true, searchText: searchBar.text ?? "")
    }
    
    private func loadTableView() {
        // >2 as paginationParams.page is updated before this method is called
        if viewModel.paginationParams.page > 2 {
            let currentCount = blockTblView.numberOfRows(inSection: 0)
            let newCount = viewModel.getNumberOfRows()
            if newCount > currentCount {
                let indexPaths = (currentCount..<newCount).map { IndexPath(row: $0, section: 0) }
                blockTblView.beginUpdates()
                blockTblView.insertRows(at: indexPaths, with: .automatic)
                blockTblView.endUpdates()
            }
        } else {
            blockTblView.reloadData()
        }
        
    }

}


extension AllBlockVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.blockTblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: "No block"
            )
        } else {
            self.blockTblView.restore()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel.getNumberOfRows()
        self.showHideEmptyState(isShow: rows == 0)
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
        cell.backView.backgroundColor = UIColor(hex: colorsList.colors[indexPath.row % 4])

        let item = viewModel.getNumberOfItem(At: indexPath)

        cell.lblTitle.text = item?.blockName
        cell.lblCode.text = item?.referenceCode
        cell.statusLbl.text = item?.statusText
        cell.lblPrice.text = "\(currency ?? "")\(item?.amount ?? 0)/"
        cell.lblDuration.text = item?.depositRules
        cell.lblDescription.text = item?.description
        cell.viewMembersCount.isHidden = Int(item?.blockMemberData?.count ?? "0") ?? 0 <= 3
        cell.lblMembersCount.text = "\(Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3)+"
        if !((item?.designation?.isEmpty) != nil) {
            cell.lblDesignation.isHidden = true
            cell.designationView.isHidden = true
        } else {
            cell.lblDesignation.isHidden = false
            cell.lblDesignation.text = item?.designation
        }
        for i in 0..<(item?.blockMemberData?.memberList?.count ?? 0){
            cell.imgMembers[i].isHidden = false
            cell.imgMembers[i].sd_setImage(with: item?.blockMemberData?.memberList?[i].profileImageUrl, placeholderImage: .none)
        }
        
        cell.statusView.backgroundColor = item?.status == "active" ? .appGreen : .appDarkPink

        self.viewDidLayoutSubviews()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)

        let vc = BlockDetailsVC(viewModel: BlockDetailViewModel(blockId: item?.blockId ?? "0"), contributionViewModel: ContributionViewModel(blockId: item?.blockId ?? "0"))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension AllBlockVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            getBlockData(page: viewModel.paginationParams.page, clearData: false, searchText: searchBar.text ?? "")
        }
        
    }
}

extension AllBlockVC:UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        getBlockData(page: 1, clearData: true, searchText: searchText)
        
        if searchText.count == 0{
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let searchText = searchBar.text else { return }
            
            // Handle the search logic here
            print("Search button clicked with text: \(searchText)")
            
            // Optionally, dismiss the keyboard
            searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        getBlockData(page: 1, clearData: true, searchText: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}
