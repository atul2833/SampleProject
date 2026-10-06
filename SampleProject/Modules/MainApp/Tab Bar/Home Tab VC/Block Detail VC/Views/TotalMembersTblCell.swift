//
//  TotalMembersTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class TotalMembersTblCell: UITableViewCell {
    
    @IBOutlet weak var collecView:UICollectionView!
    @IBOutlet weak var seeMoreMembers:ResponsiveButton!
    @IBOutlet weak var lblTotalMembers:UILabel!

    @IBOutlet weak var lblSeeMore: UILabel!
    var viewModel : BlockDetailViewModel?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collecView.register(UINib(nibName: "MemberCollViewCell", bundle: nil), forCellWithReuseIdentifier: "MemberCollViewCell")
    }
    
    func reloadData(){
        lblTotalMembers.text = "TOTAL MEMBERS (\(viewModel?.getMemberCount() ?? ""))"
        
        collecView.delegate = self
        collecView.dataSource = self
        collecView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

extension TotalMembersTblCell : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRowsForBlockMembers() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCollViewCell", for: indexPath) as! MemberCollViewCell
          
        let item = viewModel?.getNumberOfItemForBlockMembers(At: indexPath)
            cell.imgView.sd_setImage(with: item?.profileImageUrl, placeholderImage: .none)
            cell.lblTitle.text = item?.fullName
            cell.centerTitle.constant = 0//list.status == "" ? 0 : -10
            cell.countView.isHidden = true
            cell.viewNotification.isHidden = true
            cell.mainView.backgroundColor = .white
            cell.mainView.borderColor = .appGray
        
        if item?.isSwapMember == true {
            cell.lblStatus.isHidden = false

            cell.mainView.backgroundColor = .appLightGreen
            cell.mainView.borderColor = .clear
            cell.lblStatus.text = item?.designation
            cell.centerTitle.constant = -10
        }
        else if item?.designation != ""{
            cell.lblStatus.isHidden = false

            cell.lblStatus.text = item?.designation
            cell.centerTitle.constant = -10
        }
        else {
            cell.lblStatus.isHidden = true
            cell.lblStatus.text = ""
            
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = viewModel?.getNumberOfItemForBlockMembers(At: indexPath),
              let memberId = item.userId,
              let isSwapRequest = item.isSwapRequested,
                  item.isSwapMember == true,
                  let parentViewController = parentViewController else {
                return
            }
            
        let vc = RequestChatVC(viewModel: BlockDetailViewModel(blockId: viewModel?.blockId ?? ""), contributionViewModel: ContributionViewModel(blockId: viewModel?.blockId), requestChatViewModel: RequestChatViewModel(blockId: viewModel?.blockId ?? "", memberId: memberId,isSwapRequest: isSwapRequest))
            parentViewController.navigationController?.pushViewController(vc, animated: true)
        }

        var parentViewController: UIViewController? {
            var parentResponder: UIResponder? = self
            while let responder = parentResponder {
                parentResponder = responder.next
                if let viewController = parentResponder as? UIViewController {
                    return viewController
                }
            }
            return nil
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 4) / 2, height: 60)
    }
    
}

