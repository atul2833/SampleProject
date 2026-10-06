//
//  FilterRightTableVwCell.swift
//  ComeraPay
//
//  Created by NIKETAN SHARMA on 04/01/24.
//  Copyright © 2019 NimbleAppGenie. All rights reserved.
//

import UIKit

class CountryCodeTblCell: UITableViewCell
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    var imgIcon:UIImageView!
    var cellTitleLbl:UILabel!
    var cellCodeLbl:UILabel!
    
    let screenWidth = UIScreen.main.bounds.size.width

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //let screenWidth = UIScreen.mainScreen().bounds.size.width
        //let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        imgIcon = UIImageView(frame:CGRect(x: 10, y: 10, width: 30, height: 20))
        imgIcon.contentMode = UIView.ContentMode.scaleToFill
        imgIcon.cornerRadius = 6
        imgIcon.clipsToBounds = true
        imgIcon.backgroundColor = UIColor.clear
        contentView.addSubview(imgIcon)
        
        cellTitleLbl = UILabel (frame: CGRect( x: 55, y: 0, width: screenWidth-145, height: 40))
        cellTitleLbl.backgroundColor = UIColor.clear
        cellTitleLbl.font = AppFont.semi(.description)
        cellTitleLbl.textAlignment = NSTextAlignment.left
        cellTitleLbl.numberOfLines = 2
        cellTitleLbl.textColor = UIColor.black
        contentView.addSubview(cellTitleLbl)
        
        cellCodeLbl = UILabel (frame: CGRect( x: screenWidth-95, y: 0, width: 85, height: 40))
        cellCodeLbl.backgroundColor = UIColor.clear
        cellCodeLbl.font =  AppFont.regular(.description)
        cellCodeLbl.textAlignment = NSTextAlignment.right
        cellCodeLbl.numberOfLines = 2
        cellCodeLbl.textColor = UIColor.lightGray
        contentView.addSubview(cellCodeLbl)
    }
    
    func RadioBtnClckd(_ sender: UIButton!)
    {
    }
   }

