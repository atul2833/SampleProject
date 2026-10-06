//
//  String+Extension.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 29/01/2024.
//

import Foundation
import UIKit

enum DateFormatStyle {
    case customFormat(String)
    case yearMonthDayHourMinuteSecondWithDash
    case yearMonthDayHourMinuteSecondWithDashAMPM
    case dayMonthYearWithDash
    case monthDayYearWithSlash
    case hourMinuteAMPM
    case hourMinute24
    case monthDayYearShortWithSlash
    case dateTimeISO8601
    case dateWith12HourFormatWithSpace
    case utcFormat

    var formatString: String {
        switch self {
        case .yearMonthDayHourMinuteSecondWithDash:
            return "yyyy-MM-dd HH:mm"
        case .yearMonthDayHourMinuteSecondWithDashAMPM:
            return "yyyy-MM-dd HH:mm a"
        case .dayMonthYearWithDash:
            return "dd-MM-yyyy"
        case .monthDayYearWithSlash:
            return "MMM/dd/yyyy"
        case .hourMinuteAMPM:
            return "h:mm a"
        case .hourMinute24:
            return "HH:mm"
        case .monthDayYearShortWithSlash:
            return "MM/dd/yyyy"
        case .dateTimeISO8601:
            return "yyyy-MM-dd'T'HH:mm:ss"
        case .dateWith12HourFormatWithSpace:
            return "MMM d yyyy, h:mm a"
        case .utcFormat:
            return "yyyy-MM-dd'T'HH:mm:ssZ"
        case .customFormat(let customValue):
            return customValue
        }
    }
}


extension Date {
    
    func string(with format: DateFormatStyle) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.formatString
        return formatter.string(from: self)
    }
    
    func getOnlyDate() -> Date {
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date1 = Calendar.current.date(from: dateComponents)
        return date1 ?? Date()
    }
    
    func days(from date: Date) -> Int {
        let dateComponents = Calendar.current.dateComponents([.day], from: date, to: self)
        return abs(dateComponents.day ?? 0)
    }
    
    func calculateDate(beforeDays days: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = -days

        return Calendar.current.date(byAdding: dateComponents, to: self)
    }    
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
}

extension String {
    
    func date(with format: DateFormatStyle) -> Date? {
        let dateComponentsArray = self.components(separatedBy: ".")
        let dateOnlywithtime: String = dateComponentsArray[0]
        let formatter = DateFormatter()
        formatter.dateFormat = format.formatString
        return formatter.date(from: dateOnlywithtime)
    }
    
    func convertIntoDate() -> String {
        let timestampInSeconds = (Double(self) ?? 0) / 1000.0
        let date = Date(timeIntervalSince1970: timestampInSeconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy "
        return dateFormatter.string(from: date)
    }
    
    func convertBase64ToImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

