//
//  TotalAmountTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class TotalAmountTblCell: UITableViewCell {

    @IBOutlet weak var collecView:UICollectionView!
    
    var viewModel :ContributionViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collecView.register(UINib(nibName: "HomeCollecCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollecCell")
    }
    
    func reloadData(){
        collecView.delegate = self
        collecView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TotalAmountTblCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRowsDetail() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollecCell", for: indexPath) as! HomeCollecCell
          
        let countryCurrency = (AppUserDefaults.shared.UDValue(.countryCurrency) as? String) ?? "$"

        let item = viewModel?.getNumberOfItemDetail(At: indexPath)
        
            cell.ViewBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView    [indexPath.row % 5])
            cell.viewMainBack.backgroundColor = UIColor(hex: colorsList.colorsForCollectionView[indexPath.row % 5])?.withAlphaComponent(0.4)
            cell.lblImg.textColor =  UIColor(hex: colorsList.textColor[indexPath.row % 5])
            cell.lblImg.text = item?.userData?.fullName?.prefix(2).uppercased()
            cell.lblTitle.text = item?.userData?.fullName
            cell.lblAmount.text = "\(countryCurrency)\(item?.creditData?.loanAmount ?? 0.0)"
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       // sendSwitchAction(slug: slug)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 2.2, height: 100)
    }
    
}

