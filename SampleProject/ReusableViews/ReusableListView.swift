//
//  ReusableListView.swift
//  ComeraPay
//
//  Created by Muhammad Ahmed Baig on 24/01/2024.
//

import UIKit


protocol ViewModelListViewProtocol: AnyObject {
    func getItemsCountForSection() -> Int
    func getItemsCount(at section: Int) -> Int
    func getItem(for section: Int, at index: Int) -> ListItemUIModel?
    func getHeaderView(for section: Int) -> ListHeaderProtocol?
}

protocol CustomListHeaderView: UIView {
    func setupData(model: ListHeaderProtocol)
}

protocol ListHeaderProtocol {
    var customView: CustomListHeaderView { get set }
    var viewHeidht: CGFloat { get set }
}

struct ProfileStickyHeaderUIModel: ListHeaderProtocol {
    var userImg: UIImage = .iconUserPlaceholder
    var userName: String
    var mobileNumber: String
    var indicatorImg: UIImage = .iconUserPlaceholder
    var backgroundColor: UIColor
    var userNameColor: UIColor
    var mobileNumberColor: UIColor
    var customView: CustomListHeaderView
    var viewHeidht: CGFloat
    var tapAction: (()->Void)? = nil
}

struct ProfileUIModel {
    var headerView: ListHeaderProtocol?
    var items: [ListItemUIModel]
}

struct ListBGViewUIModel {
    var backgroundColor: UIColor = .clear
    var topPadding: CGFloat = 0
    var leftPadding: CGFloat = 0
    var rightPadding: CGFloat = 0
    var bottomPadding: CGFloat = 0
    var cornerRadius: CGFloat = 0
}

struct ListItemUIModel {
    enum Header {
        case accounts
        case notification
        case others
    }
    
    enum ItemType {
        case account
        case appLock
        case language
        case bankAccount
        case enableNotification
        case reportAnIssue
        case contactUs
        case aboutComeraPay
        case changePin
        case fingerPrint
        case pinLock
        case deposit
        case withDraw
    }
    
    var cellImg: UIImage
    var titleStr: String
    var titleColor: UIColor? = .appBase
    var descriptionStr: String? = nil
    var descriptionColor: UIColor? = .appBase
    var rightArrow: UIImage = .iconRightArrow
    var rightArrowHidden: Bool = false
    var haveSwitch: Bool = false
    var isSwitchOn: Bool? = false
    var needToShowSeparator: Bool = false
    var separatorColor: UIColor? = .systemGray5
    var itemHeight: CGFloat = 50.0
    var headerType: Header
    var cellType: ItemType
    var bgViewUIModel: ListBGViewUIModel = ListBGViewUIModel()
    var switchAction: (()->Void)? = nil
    var tapAction: ((ItemType)->Void)? = nil
}

class ReusableListView: UITableView {
    weak var viewModel: ViewModelListViewProtocol?
    init(viewModel: ViewModelListViewProtocol?) {
        self.viewModel = viewModel
        super.init(frame: .zero, style: .plain)
        
      //  self.register(cell: ProfileTVCell.self)
        
        self.delegate = self
        self.dataSource = self
        
        self.backgroundColor = .systemBackground
        self.separatorStyle = .none
        self.removeExtraTopPadding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadList() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}

extension ReusableListView: UITableViewDelegate,
                                  UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.getItemsCountForSection() ?? 0
    }
  
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = self.viewModel?.getHeaderView(for: section) {
            let view = headerView.customView
            view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerView.viewHeidht)
            view.setupData(model: headerView)
            return view
        }
        return nil
    }
  
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let headerView = self.viewModel?.getHeaderView(for: section) {
            return headerView.viewHeidht
        }
        return 0
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.getItemsCount(at: section) ?? 0
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeCell(cell: ProfileTVCell.self, indexPath: indexPath)
        if let item = self.viewModel?.getItem(for: indexPath.section, at: indexPath.row) {
            cell.setupData(item: item)
        }
        return cell
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.viewModel?.getItem(for: indexPath.section, at: indexPath.row) {
            item.tapAction?(item.cellType)
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
}
