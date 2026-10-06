//
//  SelectionDataModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 20/01/24.
//

import Foundation

class SelectionDataModel {
    var bankData : SelectedBankData!
    
    private var cellViewModels: [SelectionCellViewModel] = [SelectionCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    private var searchedCellViewModels: [SelectionCellViewModel] = [SelectionCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var searchedNumberOfCells: Int {
        return searchedCellViewModels.count
    }
    
        
    var reloadTableViewClosure: (()->())?
    var showAlertClosure: (()->())?
    var updateLoadingStatus: (()->())?
    
    func getSelectionList(type:String){
        self.isLoading = true
        
        
    }
    
    func getSelectedBankList(countryId:String){
        self.isLoading = true
        
       
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> SelectionCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func getSearchedCellViewModel( at indexPath: IndexPath ) -> SelectionCellViewModel {
        return searchedCellViewModels[indexPath.row]
    }
    
    func createSearchedCellViewModel(searchKey:String){
        
        var arr = [SelectionCellViewModel]()
        if searchKey.count != 0 {
            for (index, country) in cellViewModels.enumerated() {
                if country.name.lowercased().contains(searchKey.lowercased()) {
                    arr.append(country)
                }
            }
        }
        searchedCellViewModels = arr
    }
    
    func createCellViewModel( list: SelectionData) -> SelectionCellViewModel {
        
        return SelectionCellViewModel(id: list.id, name: list.name, status: list.status)
    }
    
    private func processFetchedCountry( listData: [SelectionData] ) {
        var vms = [SelectionCellViewModel]()
        for data in listData {
            vms.append( createCellViewModel(list: data) )
        }
        self.cellViewModels = vms
    }
    
    func userPressed( at indexPath: IndexPath )->SelectionCellViewModel{
       let list = getCellViewModel(at: indexPath)
        return SelectionCellViewModel(id: list.id, name: list.name, status: list.status)
    }
    
    func userSearched(searchKey:String){
        createSearchedCellViewModel(searchKey: searchKey)
    }
}


struct SelectionCellViewModel {
    let id: Int
    let name: String
    let status: String
}

