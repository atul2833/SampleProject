//
//  BlockTabVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 02/02/24.
//

import UIKit

class BlockHistoryVC: BaseNavigationController {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var collView: UICollectionView!
    private var selectedIndex = 0
    private var segmentValue = String()
    
    
    var fromeScreen = String()
    var count = String()
    private var viewModel: BlockViewModel
    private var createViewModel: CreateBlockViewModel
    private var currency  = AppUserDefaults.shared.UDValue(.countryCurrency) as? String
    
    init(viewModel: BlockViewModel, createViewModel: CreateBlockViewModel) {
        self.viewModel = viewModel
        self.createViewModel = createViewModel
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
        self.navigationItem.title = "Block History"
        stateObserver()
        setupCollectionView()
        createStateObserver()
       
        createViewModel.dropDownListData(type: "blockHistoryTypes")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBlockData(page: 1, clearData: true, searchText: "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    private func setupCollectionView() {
        collView.delegate = self
        collView.dataSource = self
        
        collView.register(
            UINib(nibName: "SegmentCell", bundle: nil),
            forCellWithReuseIdentifier: "SegmentCell"
        )
        
        if let layout = collView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 9
            layout.minimumInteritemSpacing = 9
        }
    }
    
    
    
    func getBlockData(page:Int,clearData:Bool,searchText:String){
        
        if clearData{
            viewModel.clearBlockData()
        }
        var model = viewModel.paginationParams
            model.page = page
            model.type = segmentValue
        viewModel.paginationParams = model
        self.viewModel.getBlockHistoryList()
        
       
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
    
    private func createStateObserver() {
        self.createViewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { [weak self] state in
                switch state {
                case .loading:
                    break
                case .success:
                    break
                case .listFetched:
                    self?.collView.reloadData()
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

extension BlockHistoryVC:UITableViewDelegate,UITableViewDataSource{
    
    private func showHideEmptyState(isShow: Bool) {
        if isShow {
            self.tblView.setEmptyView(
                image: UIImage(resource: .iconNoData),
                title: "No block"
            )
         //   collView.isHidden = true
        } else {
            collView.isHidden = false
            //self.tblView.restore()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = viewModel.getNumberOfRows()
        
        self.showHideEmptyState(isShow: rows == 0)
        
        return viewModel.getNumberOfRows()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockTblViewCell", for: indexPath) as! BlockTblViewCell
        
        let item = viewModel.getNumberOfItem(At: indexPath)
        setDataToTableViewCell(cell: cell, indexPath: indexPath,item: item)
        
        return cell
        
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
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.getNumberOfRows() > 0 ? 46 : 0
    }
    
    @objc func SeeMoreBlocks(_ sender: ResponsiveButton) {
        let vc = AllBlockVC(viewModel: BlockViewModel(type: sender.tag == 0 ? "created" : "invested"))
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension BlockHistoryVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let count = self.viewModel.getNumberOfRows()
        if indexPaths.contains(where: { $0.row >= count - 1 }) {
            getBlockData(page: viewModel.paginationParams.page, clearData: false, searchText: "")
        }
        
    }
}
extension BlockHistoryVC: UICollectionViewDelegate,
                          UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return createViewModel.blockSegemntList?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SegmentCell",
            for: indexPath
        ) as? SegmentCell else {
            return UICollectionViewCell()
        }
        guard let item = createViewModel.blockSegemntList?[indexPath.item] else {
                   return cell
               }
        cell.titleLbl.text = item.title
        
        // First cell selected by default
        cell.setSelected(indexPath.item == selectedIndex)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        selectedIndex = indexPath.item
        collectionView.reloadData()
        guard let selectedItem = createViewModel.blockSegemntList?[indexPath.item] else {
            return
        }
        print("Selected title:", selectedItem.title ?? "")
        print("Selected value:", selectedItem.value ?? "")
        segmentValue = selectedItem.value ?? ""
        getBlockData(page: 1, clearData: true, searchText: "")
    }
}

extension BlockHistoryVC: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        guard let item = createViewModel.blockSegemntList?[indexPath.item],
              let title = item.value else {
            return CGSize(width: 32, height: 38)
        }

        let width = title.size(
            withAttributes: [
                .font: AppFont.medium(.sectionTrailingTextSize)
            ]
        ).width

        return CGSize(
            width: width + 32,
            height: 38
        )
    }
}
