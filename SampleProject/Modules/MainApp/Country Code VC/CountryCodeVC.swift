//
//  AddHealthProfileCheckVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

protocol CountryDelegate {
    func didCountryClicked(_ country: Country)
}

var screenWidth = UIScreen.main.bounds.size.width
var screenHeight = UIScreen.main.bounds.size.height

struct Country: Codable {
    var id: Int?
    var countryName: String?
    var countryCode: String?
    var countryShortName: String?
    var countryCurrency: String?
    var currencySymbol: String?

    var status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case countryName
        case countryCode
        case countryShortName
        case countryCurrency
        case currencySymbol

    }
}

class CountryCodeVC: UIViewController {
   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!

    var delegate: CountryDelegate?

    var searchedItemsArr: [Int] = []

    var apiType = String()

    lazy var viewModel: CountryViewModel = {
        return CountryViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initVM()
        setupUI()
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func initVM() {
        
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    //self?.view.makeToast(message: message)
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    //self?.pleaseWait()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tblView.alpha = 0.0
                    })
                }else {
                   // self?.clearAllNotice()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tblView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tblView.reloadData()
                
                DispatchQueue.main.async {
                    self?.viewDidLayoutSubviews()
                }
            }
        }
        
        if apiType.count == 0{
            viewModel.loadDataFromJSON()
        }
        else{
           // viewModel.getCountryList(apiTpye: apiType)
        }
    }

    @objc func CrossBtnAction() {
        dismiss(animated: true, completion: nil)
    }

    private func setupUI() {
        searchBar.delegate = self
        searchBar.searchTextField.keyboardType = .asciiCapable
            searchBar.searchTextField.autocorrectionType = .no
        tblView.register(CountryCodeTblCell.self, forCellReuseIdentifier: "CountryCodeVwCell")
    }

    
    @IBAction func crossBtnAction(_ sender:ResponsiveButton){
        self.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CountryCodeVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView ) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text!.count > 0{
            return viewModel.searchedNumberOfCells
        }
        else{
            if searchBar.text?.count != 0{
                return 0
            }
            return viewModel.numberOfCells
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCodeVwCell", for: indexPath) as! CountryCodeTblCell

      //  let country = (searchedItemsArr.count > 0) ? countryArr[searchedItemsArr[indexPath.row]] : countryArr[indexPath.row]

        let country = searchBar.text!.count > 0 ? viewModel.getSearchedCellViewModel(at: indexPath) : viewModel.getCellViewModel(at: indexPath)
        cell.backgroundColor = UIColor.white
        cell.imgIcon.image = UIImage(named: "\(country.countryShortName.lowercased())")
        cell.cellTitleLbl.text = country.countryName
        cell.cellCodeLbl.text = country.countryCode

        return cell
          
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedCountry = searchBar.text!.count > 0 ? viewModel.userSearchedPressed(at: indexPath) : viewModel.userPressed(at: indexPath)
        
        delegate?.didCountryClicked(Country(id: selectedCountry.id, countryName: selectedCountry.countryName, countryCode: selectedCountry.countryCode, countryShortName: selectedCountry.countryShortName, countryCurrency: selectedCountry.countryCurrency))
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
    
extension CountryCodeVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.userSearched(searchKey: searchBar.text!)
    }
}

class CountryManager {
    static let shared = CountryManager()
    
    var countries: [Country] = []

    private init() {
        loadCountries()
    }

    private func loadCountries() {
        // Load your countries from the JSON file
        do {
            if let file = Bundle.main.url(forResource: "countries", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let decoder = JSONDecoder()
                countries = try decoder.decode([Country].self, from: data)
            }
        } catch {
            print("Error loading countries: \(error)")
        }
    }
    
    func getCountry(forCode countryShortName: String) -> Country{
        let foundCountry = countries.first { $0.countryShortName == countryShortName }
        return foundCountry != nil ? foundCountry! : Country(id: 226, countryName: "United Arab Emirates",countryCode: "+971", countryShortName: "AE",countryCurrency: "AED")
    }
    
    func getCountryByCode(forCode countryCode: String) -> Country{
        let foundCountry = countries.first { $0.countryCode == countryCode }
        return foundCountry != nil ? foundCountry! : Country(id: 226, countryName: "United Arab Emirates",countryCode: "+971", countryShortName: "AE",countryCurrency: "AED")
    }
    
    func getCountryByCountryId(forCode countryId: String) -> Country{
        let foundCountry = countries.first { "\($0.id ?? 228)" == countryId }
        return foundCountry != nil ? foundCountry! : Country(id: 228, countryName: "United States",countryCode: "+971", countryShortName: "US",countryCurrency: "USD")
    }
}
