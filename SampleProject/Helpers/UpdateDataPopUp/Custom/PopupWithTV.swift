//
//  PopupWithTV.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//
import UIKit

struct PopUpListUIModel {
    var title: CustomLabel.Model
    var hasBottomView: Bool
    var bottomViewColor: UIColor = .appBase
    var height: CGFloat = 55
    var tapAction: (()->Void)?
}

struct PopUpWithTVUIModel: CustomViewUIModelProtocol {
    var uiItems: [PopUpListUIModel]
    lazy var itemsHeight: CGFloat = {
        var height = uiItems.reduce(0) { $0 + $1.height}
        if height > UIScreen.main.bounds.height * 0.5 {
            return UIScreen.main.bounds.height * 0.5
        }
        return height
    }()
}

class PopupWithTV: UITableView, CustomPopupViewProtocol {
    
    private var uiModel: PopUpWithTVUIModel
    init(uiModel: PopUpWithTVUIModel) {
        self.uiModel = uiModel
        super.init(frame: .zero, style: .plain)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = self
        self.dataSource = self
        self.register(cell: PopupWithTVCell.self)
        self.separatorStyle = .none
        self.backgroundColor = .white
        self.removeExtraTopPadding()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadItems() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
}

extension PopupWithTV: UITableViewDelegate,
                       UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uiModel.uiItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeCell(cell: PopupWithTVCell.self, indexPath: indexPath)
        cell.setup(withModel: self.uiModel.uiItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.uiModel.uiItems[indexPath.row].tapAction?()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.uiModel.uiItems[indexPath.row].height
    }
}
