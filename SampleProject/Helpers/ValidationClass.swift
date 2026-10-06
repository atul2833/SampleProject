//
//  LocationPageVC.swift
//  TagCredit
//
//  Created by NIKETAN SHARMA on 01/01/24.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}


class ValidationClass: NSObject {
    
    func validateUrl (_ stringURL : NSString) -> Bool {
        
        let urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        //let urlTest = NSPredicate.predicateWithSubstitutionVariables(predicate)
        
        return predicate.evaluate(with: stringURL)
    }
    
    func isBlank (_ textfield:UITextField) -> Bool {
        
        let thetext = textfield.text
        let trimmedString = thetext!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if trimmedString.isEmpty {
            return true
        }
        return false
    }
    
    func isBlankString (_ thetext:String) -> Bool {
        
        
        let trimmedString = thetext.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if trimmedString.isEmpty {
            return true
        }
        return false
    }
    
    func isTextViewBlank(_ textview:UITextView) -> Bool {
        
        if textview.text.isEmpty {
            return true
        }
        return false
    }
    
    func isTextexceedMaxValue(_ textview:UITextView) -> Bool {
        
        if textview.text.count < 200 {
            return true
        }
        return false
    }
    
    func isAmountexceedMaxValue(_ textField:UITextField) -> Bool {
        
        if textField.text?.count < 8 {
            return true
        }
        return false
    }
    
    func isImageViewBlank(_ imageView:UIImageView)-> Bool{
        
        if imageView.image == UIImage(named: "camera") ||  imageView.image == UIImage(named: "white-logo") || imageView.image == nil {
            return true
        }
        return false
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ PhoneStr:String) -> Bool {
        
        let phoneRegEx = "[0-9]{10}"
        let range = PhoneStr.range(of: phoneRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidPWD(_ PwdStr:String) -> Bool {
        
        //let PwdRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{10,}"
        let PwdRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"

        let range = PwdStr.range(of: PwdRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return !result
    }
    
    func validateRegisterForm(_ vc : RegisterVC)-> String{

        if isBlank(vc.nameTxt){
            return Strings().name
        }
        else if isBlank(vc.emailTxt){
            return Strings().email_toast
        }
        else if !isValidEmail(vc.emailTxt.text ?? ""){
            return Strings().valid_email_toast
        }
        else if isBlank(vc.phoneTxt){
             return Strings().phone_toast
        }
        else if vc.phoneTxt.text!.count <= 5 || vc.phoneTxt.text!.count >= 15 {
             return Strings().valid_phone_toast
        }
        else if isBlank(vc.cityTxt){
             return Strings().city_toast
        }
        else{
            return ""
        }
     }
    
    func validateLoginForm(_ vc : LoginVC)-> String{
        
        if vc.phoneTxt.text!.count <= 5 || vc.phoneTxt.text!.count >= 15 {
             return Strings().empty_phone_toast
        }
        else{
            return ""
        }
     }

    func validateJointBlockForm(_ vc : JoinBlockVC)-> String{
        
        if isBlank(vc.txtBlockId) {
             return Strings().block_id_toast
        }
        else if isBlank(vc.txtBlockPassword) {
            return Strings().block_password_toast
       }
        else{
            return ""
        }
     }
    
    func validateCreateBlockForm(_ vc : CreateBlockVC)-> String{
        
        if isBlank(vc.txtName){
             return Strings().name
        }
        else if isBlank(vc.txtCity){
            return Strings().check_terms_toast
        }
        else if isBlank(vc.txtBlockName){
            return Strings().block_name_toast
        }
        else if isTextViewBlank(vc.txtDescription){
            return Strings().description_toast
        }
//        else if isTextexceedMaxValue(vc.txtDescription){
//            return Strings().description_maxlength_toast
//        }
        else if isBlank(vc.txtDepositRules){
            return Strings().amount_toast
        }
//        else if isAmountexceedMaxValue(vc.txtDepositRules){
//            return Strings().amount_maxlength_toast
//        }
        else if isBlank(vc.txtDuration){
            return Strings().duration_toast
        }
        else{
            return ""
        }
     }

    
}

extension String {
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
}

