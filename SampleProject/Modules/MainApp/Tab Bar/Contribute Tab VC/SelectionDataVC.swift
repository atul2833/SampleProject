//
//  ShowDropdownVC.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 20/01/24.
//

import UIKit

protocol SelectionDataProtocol {
    func selectedIndexData(_ comingFrom:String,_ data: SelectionData)
}

class SelectionDataVC: UIViewController  {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!

    var delegate: SelectionDataProtocol?

    var searchedItemsArr: [Int] = []

    var comingFrom = String()
    var selectedCountry:Country!

    var bankArr = ["JAMMU AND KASHIMIW BANK LIMITED","JIO PAYMENT BANK LIMITED","KARNATAKA BANK LIMITED","JANA SMALL FINANCE BANK LIMITED","JAMMU AND KASHIMIW BANK LIMITED","JIO PAYMENT BANK LIMITED","KARNATAKA BANK LIMITED","JANA SMALL FINANCE BANK LIMITED"]
    lazy var viewModel: SelectionDataModel = {
        return SelectionDataModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initVM()
        setupUI()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    @objc func CrossBtnAction() {
        dismiss(animated: true, completion: nil)
    }

    private func setupUI() {
        
        
        searchBar.delegate = self
        tblView.register(UINib(nibName: "SelectionTblCell", bundle: nil), forCellReuseIdentifier: "SelectionTblCell")
        
        self.lblTitle.text = "\(comingFrom == "occupation" ? "Occupation" : comingFrom == "supportedBank" ? "Supported Banks" : comingFrom == "sourceoffund" ? "Sourch of Funds" :"Purpose")"
    }

    
    @IBAction func crossBtnAction(_ sender:ResponsiveButton){
        self.dismiss(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SelectionDataVC:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView ) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if searchBar.text!.count > 0{
//            return viewModel.searchedNumberOfCells
//        }
//        else{
//            if searchBar.text?.count != 0{
//                return 0
//            }
//            return viewModel.numberOfCells
//        }
        
        return bankArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionTblCell", for: indexPath) as! SelectionTblCell

      //  let country = (searchedItemsArr.count > 0) ? countryArr[searchedItemsArr[indexPath.row]] : countryArr[indexPath.row]

//        let selection = searchBar.text!.count > 0 ? viewModel.getSearchedCellViewModel(at: indexPath) : viewModel.getCellViewModel(at: indexPath)
        cell.backgroundColor = UIColor.white
        cell.lblTitle.text = bankArr[indexPath.row]//selection.name

        return cell
          
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

//        if comingFrom != "supportedBank"{
//            let selectedCountry = viewModel.userPressed(at: indexPath)
//            
//            delegate?.selectedIndexData(comingFrom, SelectionData(id: selectedCountry.id, name: selectedCountry.name, status: selectedCountry.status))
//        }
//        else{
//            delegate?.selectedIndexData(comingFrom, SelectionData(id: 0, name:viewModel.bankData.fee, status: viewModel.bankData.speed))
//        }
        self.dismiss(animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
    
extension SelectionDataVC:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        viewModel.userSearched(searchKey: searchBar.text!)

        }
}


