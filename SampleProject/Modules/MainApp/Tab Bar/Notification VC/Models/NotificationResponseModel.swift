//
//  NotificationResponseModel.swift
//  TAGCredit
//
//  Created by NIKETAN SHARMA on 14/03/24.
//

import Foundation

struct NotificationResponseModel: Codable {
    var status: Bool?
    var message: String?
    var result: NotificaitonResponseDataModel?
}

struct NotificaitonResponseDataModel: Codable {
    var totalPage: Int
    var notificationList: [NotificationDataModel]?
}

struct NotificationDataModel: Codable {
    var title: String?
    var id: String?
    var message : String?
    var type : String?
    var timeDate : String?
    var requestData:NotificationRequestResponseDataModel?
}

struct NotificationRequestResponseDataModel: Codable {
    var password: String?
    var blockId: String?
    var receiverId: String?
    var invitationId: String?
    var requestId :String?
}


