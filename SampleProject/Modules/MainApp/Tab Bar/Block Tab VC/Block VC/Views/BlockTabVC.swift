//
//  BlockTabVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class BlockTabVC: BaseSlideViewController {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!

    var fromeScreen = String()
    var count = String()
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

        tblView.register(UINib(nibName: "BlockTblViewCell", bundle: nil), forCellReuseIdentifier: "BlockTblViewCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")

        tblView.removeExtraTopPadding()
        setNavigationBar()
        stateObserver()
        
        segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)

        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 14)], for: .normal)

               // Change text color and the font of the selected segment
        segmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font: AppFont.regularFont(regularFontWithSize: 14)], for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBlockData(page: 1, clearData: true, searchText: "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func setNavigationBar(){
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        customView.isUserInteractionEnabled = true // Enable user interaction

           let label = UILabel(frame: CGRect(x: 10, y: 0, width: 160, height: 40))
           label.text = "Blocks"
           label.textColor = .appBase
           label.font = AppFont.semi(.title)
        customView.addSubview(label)
       
        self.navigationItem.leftBarButtonItem =  UIBarButtonItem(customView: customView)
    }
    
    func getBlockData(page:Int,clearData:Bool,searchText:String){
        
        if clearData{
            viewModel.clearBlockData()
        }
        
        var model = viewModel.paginationParams
            model.page = page
            model.type = segmentControl.selectedSegmentIndex == 0 ? "investedBlocks" : "swapBlocks"
            model.search = searchText
        viewModel.paginationParams = model
        self.viewModel.getBlockList()
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Selected segment index: \(sender.selectedSegmentIndex)")
        
        searchBar.text = ""
        getBlockData(page: 1, clearData: true, searchText: searchBar.text ?? "")
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

extension BlockTabVC:UITableViewDelegate,UITableViewDataSource{
    
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

    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = viewModel.getNumberOfRows()//getNumberOfRowsForCreatedBlocks() + viewModel.getNumberOfRowsForInvestedBlocks()
        
        self.showHideEmptyState(isShow: rows == 0)
        
        return viewModel.getNumberOfRows()
        
//        if section == 0{
//            return viewModel.getNumberOfRowsForCreatedBlocks()
//        }
//        else{
//            return viewModel.getNumberOfRowsForInvestedBlocks()
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
        
            let item = viewModel.getNumberOfItem(At: indexPath)
            setDataToTableViewCell(cell: cell, indexPath: indexPath,item: item)
        
        return cell
        
//        if indexPath.section == 0{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
//            
//                let item = viewModel.getNumberOfItemForBlocks(At: indexPath)
//                setDataToTableViewCell(cell: cell, indexPath: indexPath,item: item)
//            
//            return cell
//        }
//        else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
//            
//                let item = viewModel.getNumberOfItemForBlocks(At: indexPath)
//                setDataToTableViewCell(cell: cell, indexPath: indexPath,item: item)
//            
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = viewModel.getNumberOfItem(At: indexPath)
       
        let vc = BlockDetailsVC(viewModel: BlockDetailViewModel(blockId: item?.blockId ?? "0"), contributionViewModel: ContributionViewModel(blockId: item?.blockId ?? "0"))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setDataToTableViewCell(cell:BlockTblViewCell,indexPath:IndexPath,item:BlockDataModel?){
      
        cell.backView.backgroundColor = UIColor(hex: colorsList.colors[indexPath.row % 4])

        cell.lblTitle.text = item?.blockName
        cell.lblCode.text = item?.referenceCode
        cell.statusLbl.text = item?.statusText
        cell.lblPrice.text = "\(currency ?? "")\(item?.amount ?? 0)/"
        cell.lblDuration.text = item?.depositRules
        cell.lblDescription.text = item?.description
        cell.lblDesignation.text = item?.designation
        if !((item?.designation?.isEmpty) != nil) {
            cell.lblDesignation.isHidden = true
            cell.designationView.isHidden = true
        } else {
            cell.lblDesignation.isHidden = false
            cell.lblDesignation.text = item?.designation
        }
        cell.viewMembersCount.isHidden = Int(item?.blockMemberData?.count ?? "0") ?? 0 <= 3
//        cell.lblMembersCount.text = "\(Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3)+"
        cell.lblMembersCount.text = "\((Int(item?.blockMemberData?.count ?? "0") ?? 0 - 3) - 3 )+"
    
        
       
        
        for i in 0..<(item?.blockMemberData?.memberList?.count ?? 0){
            cell.imgMembers[i].isHidden = false
            cell.imgMembers[i].sd_setImage(with: item?.blockMemberData?.memberList?[i].profileImageUrl, placeholderImage: .none)
        }
        
        cell.statusView.backgroundColor = item?.status == "active" ? .appGreen : .appDarkPink

        self.viewDidLayoutSubviews()
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
//        
//        cell.btnSeeMore.tag = section
//        cell.btnSeeMore.addTarget(self, action: #selector(SeeMoreBlocks(_:)), for: .touchUpInside)
//        cell.backView.backgroundColor = .white
//        return cell.contentView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return viewModel.getNumberOfRowsForBlocks() > 0 ? 44 : 0
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let count = viewModel.getNumberOfCount()
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
        cell.lblTitle.text = segmentControl.selectedSegmentIndex == 0 ? "My BLOCKS (\(count))" : "BLOCKS AVAILABLE FOR SWAP"
        cell.backView.backgroundColor = UIColor.white
        cell.backLabel.backgroundColor = UIColor.appLightGrayText
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //return viewModel.getNumberOfRows() > 0 ? 46 : 0
        return  46
    }
    
    @objc func SeeMoreBlocks(_ sender: ResponsiveButton) {
        let vc = AllBlockVC(viewModel: BlockViewModel(type: sender.tag == 0 ? "created" : "invested"))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension BlockTabVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            getBlockData(page: viewModel.paginationParams.page, clearData: false, searchText: searchBar.text ?? "")
        }
        
    }
}

extension BlockTabVC:UISearchBarDelegate{
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
