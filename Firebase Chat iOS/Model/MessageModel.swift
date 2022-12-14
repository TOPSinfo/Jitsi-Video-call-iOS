//
//  MessageModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// Comversation model
class MessageClass{

    var messageText : String = ""
    var receiverId : String = ""
    var senderId : String = ""
    var timestamp : String?
    var url : String = ""
    var video_url : String = ""
    var message_type : String = ""
    var status : String = ""
    var type : DocumentChangeType?
    var docId : String = ""
    var task : StorageUploadTask?
    var reference : StorageReference?
    var videoTask : StorageUploadTask?
    var videoRef : StorageReference?
    
    init() {
        
    }

    init(fromDictionary dictionary: [String:Any]){
        messageText = dictionary["messageText"] as? String ?? ""
        receiverId = dictionary["receiverId"] as? String ?? ""
        senderId = dictionary["senderId"] as? String ?? ""
        timestamp = ""
        let time = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ssZ"
        if let date = dfmatter.date(from: time.dateValue().description) {
            dfmatter.amSymbol = "AM"
            dfmatter.pmSymbol = "PM"
            dfmatter.dateFormat = "dd MM yyyy HH:mm a"
            timestamp = dfmatter.string(from: date)
        }
        
        url = dictionary["url"] as? String ?? ""
        video_url = dictionary["video_url"] as? String ?? ""
        message_type = dictionary["message_type"] as? String ?? ""
        status = dictionary["status"] as? String ?? ""
        docId = dictionary["docId"] as? String ?? ""
    }

}
