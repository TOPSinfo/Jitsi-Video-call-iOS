//
//  ActiveCallList.swift
//  SampleCodeiOS
//
//  Created by Mohak Parmar on 19/10/21.
//

import UIKit

class ActiveCallList: NSObject {

    var CallStatus: String = ""
    var HostId: String = ""
    var HostName: String = ""
    var documentId: String = ""
    var userIds: [String] = []

    override init() {

    }

    init(fromDictionary dictionary: [String: Any], dId: String) {
        CallStatus = dictionary["CallStatus"] as? String ?? ""
        HostId = dictionary["HostId"] as? String ?? ""
        HostName = dictionary["HostName"] as? String ?? ""
        userIds = dictionary["userIds"] as? [String] ?? []
        documentId = dId
    }
}
