//
//  ActiveCallList.swift
//  SampleCodeiOS
//
//  Created by Mohak Parmar on 19/10/21.
//

import UIKit

class ActiveCallList: NSObject {

    var callStatus: String = ""
    var hostId: String = ""
    var hostName: String = ""
    var documentId: String = ""
    var userIds: [String] = []

    override init() {

    }

    init(fromDictionary dictionary: [String: Any], dId: String) {
        callStatus = dictionary["CallStatus"] as? String ?? ""
        hostId = dictionary["HostId"] as? String ?? ""
        hostName = dictionary["HostName"] as? String ?? ""
        userIds = dictionary["userIds"] as? [String] ?? []
        documentId = dId
    }
}
