//
//  UserModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation
import FirebaseFirestore
import UIKit
import FirebaseAuth

// This is user model
class SignupUserData: NSObject {

    var email: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var phone: String = ""
    var uid: String = ""
    var profileImage: String = ""
    var createdAt: Timestamp = Timestamp(date: Date())
    var isOnline: Bool = false
    var type: DocumentChangeType?
    var isGroup: Bool = false
    var objGroupDetail: GroupDetailObject?

    override init() {

    }

    init(fromDictionary dictionary: [String: Any]) {
        print(dictionary)
        email = dictionary["email"] as? String ?? ""
        firstName = dictionary["first_name"] as? String ?? ""
        lastName = dictionary["last_name"] as? String ?? ""
        phone = dictionary["phone"] as? String ?? ""
        uid = dictionary["uid"] as? String ?? ""
        profileImage = dictionary["profile_image"] as? String ?? ""
        isOnline = dictionary["isOnline"] as? Bool ?? false
        createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        print("\(firstName) \(createdAt.dateValue())")
        isGroup = false
    }

    init(fromDictionaryGroup dictionary: [String: Any]) {
        email = ""
        firstName = dictionary["name"] as? String ?? ""
        lastName = ""
        phone = dictionary["phone"] as? String ?? ""
        uid = dictionary["id"] as? String ?? ""
        profileImage = dictionary["groupIcon"] as? String ?? ""
        isOnline = dictionary["isOnline"] as? Bool ?? false
        isGroup = true
        createdAt = dictionary["createdAt"] as? Timestamp ?? Timestamp(date: Date())
        objGroupDetail = GroupDetailObject(fromDictionary: dictionary)
    }

    var fullName: String {
        firstName + " " + lastName
    }
}

// This is group model
class GroupDetailObject {

    var adminId: String = ""
    var adminName: String = ""
    var createdAt: String = ""
    var groupIcon: String = ""
    var gid: String = ""
    var members: [String] = []
    var name: String = ""

    init() {

    }

    init(fromDictionary dictionary: [String: Any]) {
        adminId = dictionary["adminId"] as? String ?? ""
        adminName = dictionary["adminName"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? String ?? ""
        groupIcon = dictionary["groupIcon"] as? String ?? ""
        gid = dictionary["id"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        members = dictionary["members"] as? [String] ?? []
    }
}
