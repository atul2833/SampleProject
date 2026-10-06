//
//  CountryViewModel.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 19/01/24.
//

import Foundation

class CountryViewModel {
            
    private var cellViewModels: [CountryCellViewModel] = [CountryCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    private var searchedCellViewModels: [CountryCellViewModel] = [CountryCellViewModel]() {
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

    func loadDataFromJSON() {
        do {
            if let file = Bundle.main.url(forResource: "countries", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let countries = try JSONDecoder().decode([Country].self, from: data)
                
                self.processFetchedCountry(listData: countries)

            } else {
                print("no file")
            }
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
//    func getCountryList(apiTpye:String){
//        
//        self.isLoading = true
//        
//        APIService.shared.request(service: .transaction,endpoint: APIServiceName.Transaction.getCountryList.rawValue, method: "GET", accessTokenRequired: true, parameters: [:]) { (response: APIResponse<APIResponseData<[Country]?>>) in
//            
//            self.isLoading = false
//
//            switch response {
//            case .success(let list):
//                
//                DispatchQueue.main.async {
//                    self.processFetchedCountry(listData: list.data!)
//                }
//            case .failure(let error):
//                // Handle login failure
//                print("getNotificationsList error: N\(error.localizedDescription)")
//                self.alertMessage = error.localizedDescription
//            default:
//                print("Comera")
//            }
//        }
//    }
    
    
    func getCellViewModel( at indexPath: IndexPath ) -> CountryCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    func getSearchedCellViewModel( at indexPath: IndexPath ) -> CountryCellViewModel {
        return searchedCellViewModels[indexPath.row]
    }
    
    func createSearchedCellViewModel(searchKey:String){
        
        var arr = [CountryCellViewModel]()
        if searchKey.count != 0 {
            for (index, country) in cellViewModels.enumerated() {
                if country.countryName.lowercased().contains(searchKey.lowercased()) {
                    arr.append(country)
                }
            }
        }
        searchedCellViewModels = arr
    }
    
    func createCellViewModel( list: Country) -> CountryCellViewModel {
        
        return CountryCellViewModel(id: list.id!, countryName: list.countryName!, countryCode: list.countryCode!, countryShortName: list.countryShortName!, countryCurrency: list.countryCurrency!, currencySymbol: list.currencySymbol!)
    }
    
    private func processFetchedCountry( listData: [Country] ) {
        var vms = [CountryCellViewModel]()
        for data in listData {
            vms.append( createCellViewModel(list: data) )
        }
        self.cellViewModels = vms
    }
    
    func userPressed( at indexPath: IndexPath )->CountryCellViewModel{
       let list = getCellViewModel(at: indexPath)
        return CountryCellViewModel(id: list.id, countryName: list.countryName, countryCode: list.countryCode, countryShortName: list.countryShortName, countryCurrency: list.countryCurrency, currencySymbol: list.currencySymbol)
    }
    
    func userSearchedPressed( at indexPath: IndexPath )->CountryCellViewModel{
       let list = getSearchedCellViewModel(at: indexPath)
        return CountryCellViewModel(id: list.id, countryName: list.countryName, countryCode: list.countryCode, countryShortName: list.countryShortName, countryCurrency: list.countryCurrency,currencySymbol: list.currencySymbol)
    }
    
    func userSearched(searchKey:String){
        createSearchedCellViewModel(searchKey: searchKey)
    }
}


struct CountryCellViewModel {
    var id: Int
    var countryName: String
    var countryCode: String
    var countryShortName: String
    var countryCurrency: String
    var currencySymbol: String
}
