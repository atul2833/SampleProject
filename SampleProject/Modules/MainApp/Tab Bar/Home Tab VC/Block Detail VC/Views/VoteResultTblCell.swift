//
//  VoteResultTblCell.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import UIKit

class VoteResultTblCell: UITableViewCell {

    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var btnCancel:ResponsiveButton!

    var viewModel : BlockDetailViewModel?
    var itemActionDetail: ((String?,String?,String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        tblView.register(UINib(nibName: "MemberSelectedTblCell", bundle: nil), forCellReuseIdentifier: "MemberSelectedTblCell")
        
    }

    func reloadData(){
        tblView.delegate = self
        tblView.dataSource = self
        
        tblView.reloadData()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension VoteResultTblCell:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getNumberOfRowsForVotingResult() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberSelectedTblCell", for: indexPath) as! MemberSelectedTblCell
        
        let item = viewModel?.getNumberOfItemForVotingResult(At: indexPath)

        cell.imgUser.sd_setImage(with: item?.profileImageUrl, placeholderImage: .none)

        cell.lblName.text = item?.fullName
        cell.lblVoteCount.text = "\(item?.voteCount ?? "0" == "0" || item?.voteCount ?? "1" == "1" ? "\(item?.voteCount ?? "0") Vote" : "\(item?.voteCount ?? "0") Votes")"
        cell.typeLbl.text = item?.designation?.uppercased()
        cell.lblDescrition.text = "\(item?.fullName ?? "") is \(item?.designation ?? "") of this Block"
        
//        cell.btnForVote.tag = indexPath.row
//        cell.btnForVote.addTarget(self, action: #selector(voteBtnAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel?.getNumberOfItemForVotingResult(At: indexPath)

        self.itemActionDetail?("1",item?.userId,item?.pollId)
    }
    
//    @objc func voteBtnAction(_ sender:ResponsiveButton){
//        let item = viewModel?.getNumberOfItemForVotingResult(At: IndexPath(row: sender.tag, section: 0))
//        self.itemActionDetail?("1",item?.userId,item?.pollId)
//
//    }
}
