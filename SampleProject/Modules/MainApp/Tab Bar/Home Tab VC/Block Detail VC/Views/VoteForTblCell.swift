//
//  VoteForTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class VoteForTblCell: UITableViewCell {
    
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblBottomDescription:UILabel!
    var viewModel : BlockDetailViewModel?
    var index:Int = 0
    
    var itemActionVoteCount: ((String?,String?) -> Void)?
    var itemActionDetail: ((String?,String?,String?) -> Void)?
    var itemActionViewMore: ((String?) -> Void)?

    
    override func awakeFromNib(){
        super.awakeFromNib()
        
        tblView.register(UINib(nibName: "MemberBlockTblCell", bundle: nil), forCellReuseIdentifier: "MemberBlockTblCell")
        tblView.register(UINib(nibName: "TitleHeaderTblCell", bundle: nil), forCellReuseIdentifier: "TitleHeaderTblCell")
        tblView.register(UINib(nibName: "SeeMoreFooterTblCell", bundle: nil), forCellReuseIdentifier: "SeeMoreFooterTblCell")
        tblView.removeExtraTopPadding()
    }

    func reloadData(){
        
        lblTitle.text = "Votes for \(index == 5 ? "" : "Assistant ")Manager"
        lblBottomDescription.text = index == 5 ? viewModel?.getMemberExpirtTimeManager() ?? "" : viewModel?.getMemberExpirtTimeAsstManager() ?? ""
        
        tblView.delegate = self
        tblView.dataSource = self
        
        tblView.reloadData()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension VoteForTblCell:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return index == 5 ? viewModel?.getNumberOfRowsForBlockMembersManager() ?? 0 : viewModel?.getNumberOfRowsForBlockMembersAsstManager() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberBlockTblCell", for: indexPath) as! MemberBlockTblCell
        
        let item = index == 5 ? viewModel?.getNumberOfItemForBlockMembersManager(At: indexPath) : viewModel?.getNumberOfItemForBlockMembersAsstManager(At: indexPath)

        cell.imgUser.sd_setImage(with: item?.profileImageUrl, placeholderImage: .none)

        cell.lblName.text = item?.fullName
        cell.lblVoteCount.text = "\(item?.voteCount ?? "0" == "0" || item?.voteCount ?? "0" == "1" ? "\(item?.voteCount ?? "0") Vote" : "\(item?.voteCount ?? "0") Votes")"
        
        cell.btnForVote.tag = Int(item?.userId ?? "0") ?? 0
        cell.btnForVote.addTarget(self, action: #selector(btnForVoteAction(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleHeaderTblCell") as! TitleHeaderTblCell
        cell.lblTitle.text = "TOP \(index == 5 ? viewModel?.getMemberCountMananger() ?? "0": viewModel?.getMemberCountAsstManager() ?? "0") MEMBERS"
    //    cell.backView.backgroundColor = UIColor.white
        cell.backLabel.backgroundColor = UIColor.systemGray5
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return index == 5 ? ((viewModel?.getNumberOfRowsForBlockMembersManager() ?? 0) > 0 ? 30 : 0) : (((viewModel?.getNumberOfRowsForBlockMembersAsstManager() ?? 0) != 0) ? 30 : 0)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreFooterTblCell") as! SeeMoreFooterTblCell
            cell.btnSeeMore.addTarget(self, action: #selector(footerButtonTapped(_:)), for: .touchUpInside)
        return cell.contentView
    }
    
  
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return index == 5 ? ((viewModel?.getNumberOfRowsForBlockMembersManager() ?? 0) > 0 ? 30 : 0) : (((viewModel?.getNumberOfRowsForBlockMembersAsstManager() ?? 0) != 0) ? 30 : 0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = index == 5 ? viewModel?.getNumberOfItemForBlockMembersManager(At: indexPath) : viewModel?.getNumberOfItemForBlockMembersAsstManager(At: indexPath)

        self.itemActionDetail?("\(item?.voteCount != "0" ? index : 0)",item?.userId,index == 5 ? viewModel?.getPollIdManager() : viewModel?.getPollIdAsstManager())
       
    }
    
    @objc func footerButtonTapped(_ sender: ResponsiveButton) {
        self.itemActionViewMore?("\(index)")
    }
    
    @objc func btnForVoteAction(_ sender: ResponsiveButton) {
        self.itemActionVoteCount?("\(index)","\(sender.tag)")
    }
}
