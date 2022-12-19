//
//  ChatVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import IQKeyboardManagerSwift
import TLPhotoPicker
import CropViewController
import AVKit
import SKPhotoBrowser

// MARK: - Custom delegate
protocol ChatVCDelegate: AnyObject {
    func uploadMediea(_ filename: String, file: Data, type: MediaType)
    func uploadVideo(_ files: [(filename: String, file: Data, type: MediaType)])
    func getMessageList(_ touserID: String, isForGroup: Bool)
    func sendMessage(conversationID: String, messageID: String, dic: [String: Any])
    func checkUserisOnline(_ senderID: String)
}

class ChatVC: UIViewController {

    var objJitsi: JitsiManager = JitsiManager()

    // MARK: - chat view model object
    let chatviewmodel: ChatViewModel = ChatViewModel()
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()

    // MARK: - outlet
    @IBOutlet weak var tvMessage: KMPlaceholderTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var constantHtTextfview: NSLayoutConstraint!

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblIsOnline: UILabel!

    @IBOutlet weak var contantBottomOfTextfield: NSLayoutConstraint!

    @IBOutlet weak var btnCameraInfo: UIButton!

    // MARK: - Variable
    var userID = String()
    var messaes = [MessageClass]()
    var isFirstTime = true
    var userName = String()

    var selectedAssets = [TLPHAsset]()
    var objOppoUser: SignupUserData = SignupUserData()
    var arrayForGroupUserDetails: [SignupUserData] = []

    @IBOutlet weak var btnGroupInfo: UIButton!
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - user to dismiss keyboar  on touch
        self.dismissKey()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        chatviewmodel.firebasechatViewModelDelegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    // MARK: - Setup UI
    func setupView() {

        self.lblTitle.text = userName

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                                   name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        tblChat.register(UINib(nibName: "ChatReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverCell")
        tblChat.register(UINib(nibName: "ChatSenderCell", bundle: nil), forCellReuseIdentifier: "ChatSenderCell")
        tblChat.register(UINib(nibName: "ChatReceiverImageCell", bundle: nil),
                         forCellReuseIdentifier: "ChatReceiverImageCell")
        tblChat.register(UINib(nibName: "ChatSenderImageCell", bundle: nil),
                         forCellReuseIdentifier: "ChatSenderImageCell")
        
        tblChat.delegate = self
        tblChat.dataSource = self
        
        chatviewmodel.chatVCDelegate?.getMessageList(userID, isForGroup: objOppoUser.isGroup)
        chatviewmodel.chatVCDelegate?.checkUserisOnline(userID)
        
        if objOppoUser.isGroup {
            btnGroupInfo.isHidden = false
            lblIsOnline.isHidden = true
            for item in self.objOppoUser.objGroupDetail?.members ?? [] {
                
                if item.isEmpty { continue }
                
                firebaseViewModel.firebaseCloudFirestoreManager.getUserDetail(userID: item) { objUser in
                    self.arrayForGroupUserDetails.append(objUser)
                    if self.arrayForGroupUserDetails.count == self.objOppoUser.objGroupDetail?.members.count {
                        self.reloadVisibleCells()
                    }
                } failure: { _ in
                    
                }
            }
        }
    }
    
    func reloadVisibleCells() {
        guard let visibleRows = tblChat.indexPathsForVisibleRows else { return }
        tblChat.beginUpdates()
        tblChat.reloadRows(at: visibleRows, with: .none)
        tblChat.endUpdates()
    }
    
    // MARK: - Keyboard methods
    func dismissKey() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self,
                                                                  action: #selector(dismissKeyboard(sender:)))
        tap.cancelsTouchesInView = false
        tblChat.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.contantBottomOfTextfield.constant == 8 {
                if #available(iOS 13.0, *) {
                    let window = Singleton.appDelegate?.window
                    let bottomPadding = window?.safeAreaInsets.bottom
                    UIView.animate(withDuration: 1.0) {
                        self.contantBottomOfTextfield.constant = keyboardSize.height + 8 - (bottomPadding ?? 0)
                        self.view.layoutSubviews()
                    }
                } else {
                    let window = Singleton.appDelegate?.window
                        let bottomPadding = window?.safeAreaInsets.bottom
                    
                    UIView.animate(withDuration: 1.0) {
                        self.contantBottomOfTextfield.constant = keyboardSize.height + 8 - (bottomPadding ?? 0)
                        self.view.layoutSubviews()
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.contantBottomOfTextfield.constant != 0 {
            self.contantBottomOfTextfield.constant = 8
        }
    }

    // MARK: - will scroll at last position when new message arrive or send
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.tblChat.numberOfRows(inSection: 0) - 1,
                section: 0)
            if self.tblChat.numberOfRows(inSection: 0) > 1 {
                self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    // MARK: - Button Action
    @IBAction func btn_sendMessageTapped(_ sender: UIButton) {
        
        if tvMessage.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.AlertMessages.enterMessage)
            return
        }

        let senderID = Auth.auth().currentUser?.uid ?? ""
        var converastionID = Singleton.sharedSingleton.getOneToOneID(senderID: senderID, receiverID: userID)
        if objOppoUser.isGroup {
            converastionID = objOppoUser.uid
        }
        
        let dbc: CollectionReference = Firestore.firestore().collection("Messages")
        let messageID = dbc.document(converastionID).collection("message").document().documentID
        var dic = [String: Any]()
        dic["docId"] = messageID
        dic["messageText"] = self.tvMessage.text ?? ""
        dic["receiverId"] = userID
        dic["senderId"] = senderID // Current User
        dic["timestamp"] = Timestamp.init(date: Date())
        dic["image_url"] = ""
        dic["video_url"] = ""
        dic["message_type"] = Singleton.MessageType.TEXT
        dic["status"] = Singleton.MessageStatus.SEND
        
        // MARK: - this will call send message controller
        self.chatviewmodel.chatVCDelegate?.sendMessage(conversationID: converastionID, messageID: messageID, dic: dic)
    }
    
    @IBAction func btnVCallClick(_ sender: Any) {
        var arrUsers: [String] = []
        if objOppoUser.isGroup {
            arrUsers.append(contentsOf: objOppoUser.objGroupDetail?.members ?? [])
        } else {
            arrUsers.append(Auth.auth().currentUser?.uid ?? "")
            arrUsers.append(objOppoUser.uid)
        }
        var isActiveCall: Bool = false
        for item in AppDelegate.standard.arrForActiveCallList {
            var isAllAvailable: Bool = true
            for userId in arrUsers {
                if item.userIds.contains(userId + "___InActive") || item.userIds.contains(userId + "___Active") {
                } else {
                    isAllAvailable = false
                    break
                }
            }
            if isAllAvailable == true && item.userIds.count == arrUsers.count {
                isActiveCall = true
                self.objJitsi.viewController = self
                self.objJitsi.openJetsiViewWithUser(roomid: item.documentId)
                print("video call found")
                break
            } else {
                isActiveCall = false
            }
        }
        if isActiveCall == false {
            if let row = arrUsers.firstIndex(where: {$0 == ((Auth.auth().currentUser?.uid ?? ""))}) {
                arrUsers.remove(at: row)
            }
            firebaseViewModel.firebaseCloudFirestoreManager.addGroupCallForDetailPage(arr: arrUsers) { (docId) in
                self.objJitsi.viewController = self
                self.objJitsi.openJetsiViewWithUser(roomid: docId)
            } failure: { (_) in
                
            }
        }
    }
    
    @IBAction func btnGroupInfoClick(_ sender: Any) {
        guard let vcCG = Singleton.sharedSingleton.getController(storyName: Singleton.StoryboardName.Main,
                        controllerName: Singleton.ControllerName.CreateGroupVC) as? CreateGroupVC else { return }
        vcCG.objGroup = self.objOppoUser.objGroupDetail ?? GroupDetailObject()
        vcCG.isForDetail = true
        self.present(vcCG, animated: true, completion: nil)
    }
    
    @IBAction func btn_backTapped(_ sender: UIButton) {
        Singleton.converstaonListner?.remove()
        Singleton.onlineOfflineLisnter?.remove()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_pickPhoto(_ sender: UIButton) {
        openImagePicker(self)
    }
    
    deinit {
        Singleton.converstaonListner?.remove()
        Singleton.onlineOfflineLisnter?.remove()
    }
}

// MARK: - Tableview Delegate
extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messaes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.messaes[indexPath.row]
        
        if item.senderId == Auth.auth().currentUser?.uid ?? "" {
            
            if item.messageType == Singleton.MessageType.IMAGE {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderImageCell") as? ChatSenderImageCell
                cell?.imgMedia.setUserImageUsingUrl(item.url, isUser: false)
                cell?.btnPlay.isHidden = true
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(btn_showFullImage(_:)))
                cell?.imgMedia.isUserInteractionEnabled = true
                cell?.imgMedia.tag = indexPath.row
                cell?.imgMedia.addGestureRecognizer(tap)
                cell?.lblDate.text = item.timestamp
                
                if item.status == Singleton.MessageStatus.SEND {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_singletick")
                } else if item.status == Singleton.MessageStatus.READ {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_Double_Click")
                } else if item.status == Singleton.MessageStatus.UPLOADING {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_clock")
                }
                
                cell?.viewCircelProgress.isHidden = true
                
                if let task = item.task {
                    _ = task.observe(.progress) { snapshot in
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                        cell?.viewCircelProgress.progress = Float(percentComplete)
                        print(percentComplete)
                        cell?.viewCircelProgress.isHidden = false
                        if percentComplete == 100 {
                            cell?.viewCircelProgress.isHidden = true
                            // MARK: - this will call send message controller
                            var filter = Singleton.localFileUpload.filter({$0["docId"] as? String ?? "" == item.docId})
                            if filter.count > 0 {
                                Singleton.localFileUpload.removeAll(where: {$0["docId"] as? String ?? "" == filter[0]["docId"] as? String ?? ""})
                                item.reference!.downloadURL { (url, _) in
                                    guard let downloadURL = url else {
                                        return
                                    }
                                    filter[0]["url"] = downloadURL.description
                                    filter[0]["status"] = Singleton.MessageStatus.SEND
                                    // MARK: - this will call send message controller
                                    var converastionID = Singleton.sharedSingleton.getOneToOneID(senderID: item.senderId, receiverID: self.userID)
                                    if self.objOppoUser.isGroup {
                                        converastionID = self.objOppoUser.uid
                                    }
                                    let messageID = filter[0]["docId"] as? String ?? ""
                                    self.chatviewmodel.chatVCDelegate?.sendMessage(conversationID: converastionID, messageID: messageID, dic: filter[0])
                                }
                                
                                print(item.url)
                            }
                        }
                    }
                } else {
                    cell?.viewCircelProgress.isHidden = true
                }
                
                return cell ?? UITableViewCell()
                
            } else if item.messageType == Singleton.MessageType.VIDEO {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderImageCell") as? ChatSenderImageCell
                cell?.btnPlay.isHidden = false
                cell?.imgMedia.setUserImageUsingUrl(item.url, isUser: false)
                if item.status == Singleton.MessageStatus.SEND {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_singletick")
                } else if item.status == Singleton.MessageStatus.READ {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_Double_Click")
                } else if item.status == Singleton.MessageStatus.UPLOADING {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_clock")
                }
                
                cell?.btnPlay.addTarget(self, action: #selector(btn_play(_:)), for: .touchUpInside)
                cell?.btnPlay.tag = indexPath.row
                cell?.lblDate.text = item.timestamp
                var filter = Singleton.localFileUpload.filter({$0["docId"] as? String ?? "" == item.docId})
                if let task = item.task {
                    _ = task.observe(.success) { snapshot in
                        // Upload completed successfully
                        if filter.count > 0 {
                            item.reference!.downloadURL { (url, _) in
                                guard let downloadURL = url else {
                                    return
                                }
                                filter[0]["url"] = downloadURL.description
                            }
                            print(item.url)
                        }
                    }
                }
                cell?.viewCircelProgress.isHidden = true
                
                if let task = item.videoTask {
                    _ = task.observe(.progress) { snapshot in
                        let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                        / Double(snapshot.progress!.totalUnitCount)
                        cell?.viewCircelProgress.progress = Float(percentComplete)
                        cell?.viewCircelProgress.isHidden = percentComplete == 100.0
                        
                    }
                    _ = task.observe(.success) { snapshot in
                        // Upload completed successfully
                        cell?.viewCircelProgress.isHidden = true
                        if filter.count > 0 {
                            Singleton.localFileUpload.removeAll(where: {$0["docId"] as? String ?? "" == filter[0]["docId"] as? String ?? ""})
                            item.videoRef!.downloadURL { (url, _) in
                                guard let downloadURL = url else {
                                    return
                                }
                                filter[0]["video_url"] = downloadURL.description
                                filter[0]["status"] = Singleton.MessageStatus.SEND
                                // MARK: - this will call send message controller
                                var converastionID = Singleton.sharedSingleton.getOneToOneID(senderID: item.senderId, receiverID: self.userID)
                                if self.objOppoUser.isGroup {
                                    converastionID = self.objOppoUser.uid
                                }
                                let messageID = filter[0]["docId"] as? String ?? ""
                                self.chatviewmodel.chatVCDelegate?.sendMessage(conversationID: converastionID, messageID: messageID, dic: filter[0])
                            }
                            print(item.url)
                        }
                    }
                } else {
                    cell?.viewCircelProgress.isHidden = true
                }

                
                return cell ?? UITableViewCell()
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderCell") as? ChatSenderCell
                cell?.lblMessage.text = item.messageText
                cell?.layoutSubviews()

                if item.status == Singleton.MessageStatus.SEND {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_singletick")
                } else if item.status == Singleton.MessageStatus.READ {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_Double_Click")
                } else if item.status == Singleton.MessageStatus.UPLOADING {
                    cell?.imgTick.image = #imageLiteral(resourceName: "ic_clock")
                }
                
                cell?.lblDate.text = item.timestamp
                DispatchQueue.main.async {
                    cell?.viewBubble.roundCorners([.topLeft, .bottomLeft, .bottomRight], radius: 5)
                }
                return cell ?? UITableViewCell()
            }
        } else {
            
            if item.messageType == Singleton.MessageType.IMAGE {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverImageCell") as? ChatReceiverImageCell
                cell?.imgMedia.setUserImageUsingUrl(item.url, isUser: false)
                cell?.btnPlay.isHidden = true
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(btn_showFullImage(_:)))
                cell?.imgMedia.isUserInteractionEnabled = true
                cell?.imgMedia.tag = indexPath.row
                cell?.imgMedia.addGestureRecognizer(tap)
                cell?.lblDate.text = item.timestamp
                if objOppoUser.isGroup {
                    let arr = arrayForGroupUserDetails.filter( {$0.uid == item.senderId })
                    if arr.count > 0 {
                        cell?.lblUserName.text = arr[0].fullName
                    }
                } else {
                    cell?.consUserNameHeight.constant = 0
                }
                return cell ?? UITableViewCell()
                
            } else if item.messageType == Singleton.MessageType.VIDEO {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverImageCell") as? ChatReceiverImageCell
                cell?.btnPlay.isHidden = false
                cell?.imgMedia.setUserImageUsingUrl(item.url, isUser: false)
                cell?.btnPlay.addTarget(self, action: #selector(btn_play(_:)), for: .touchUpInside)
                cell?.btnPlay.tag = indexPath.row
                cell?.lblDate.text = item.timestamp
                if objOppoUser.isGroup {
                    let arr = arrayForGroupUserDetails.filter({ $0.uid == item.senderId })
                    if arr.count > 0 {
                        cell?.lblUserName.text = arr[0].fullName
                    }
                } else {
                    cell?.consUserNameHeight.constant = 0
                }
                return cell ?? UITableViewCell()
            } else {
            
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverCell") as? ChatReceiverCell else {
                    return UITableViewCell()
                }
                cell.lblMessage.text = item.messageText
                cell.layoutSubviews()
                cell.lblDate.text = item.timestamp
                DispatchQueue.main.async {
                    cell.viewBubble.roundCorners([.topRight, .bottomLeft, .bottomRight], radius: 5)
                }
                if objOppoUser.isGroup {
                    let arr = arrayForGroupUserDetails.filter({ $0.uid == item.senderId })
                    if arr.count > 0 {
                        cell.lblUserName.text = arr[0].fullName
                    }
                } else {
                    cell.consUserNameHeight.constant = 0
                }
                return cell
            }
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    @objc func btn_play(_ sender: UIButton) {
        
        let item = self.messaes[sender.tag]
        if item.messageType == Singleton.MessageType.VIDEO {
            if let url = URL(string: item.videoUrl) {
                let player = AVPlayer(url: url)
                let vcPlayer = AVPlayerViewController()
                vcPlayer.player = player
                vcPlayer.player?.play()
                self.present(vcPlayer, animated: true, completion: nil)
            }
        }
    }
    
    @objc func btn_showFullImage(_ sender: UITapGestureRecognizer) {
        
        guard let imgview = sender.view as? UIImageView else {
            return
        }
        
        if let image = imgview.image {
            
            var images = [SKPhoto]()
            let photo = SKPhoto.photoWithImage(image)
            photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
            images.append(photo)

            // 2. create PhotoBrowser Instance, and present.
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(0)
            present(browser, animated: true, completion: {})
        }
    }
}

// MARK: - Extended firebase chat medel view
extension ChatVC: FirebaseChatViewModelDelegate {
    
    func didCheck(_ isOnline: Bool) {
        print(isOnline)
        self.lblIsOnline.text = isOnline ? "Online":"Offline"
    }
    
    func didUploadVideo(_ imageRef: StorageReference?, imageTask: StorageUploadTask?, videoRef: StorageReference?, videoTask: StorageUploadTask?) {
        
        let senderID = Auth.auth().currentUser?.uid ?? ""
        var converastionID = Singleton.sharedSingleton.getOneToOneID(senderID: senderID, receiverID: userID)
        if objOppoUser.isGroup {
            converastionID = objOppoUser.uid
        }
        let db: Firestore = Firestore.firestore()
        let messageID = db.collection("Messages").document(converastionID).collection("message").document().documentID
        var dic = [String: Any]()
        dic["docId"] = messageID
        dic["messageText"] = ""
        dic["receiverId"] = userID
        dic["senderId"] = senderID
        dic["timestamp"] = Timestamp.init(date: Date())
        dic["url"] = ""
        dic["video_url"] = ""
        dic["message_type"] = Singleton.MessageType.VIDEO
        dic["status"] = Singleton.MessageStatus.UPLOADING
                
        let message = MessageClass.init(fromDictionary: dic)
        message.task = imageTask
        message.reference = imageRef
        message.videoTask = videoTask
        message.videoRef = videoRef
        
        Singleton.localFileUpload.append(dic)
        self.messaes.append(message)
        self.tblChat.reloadData()
        scrollToBottom()
        
        // MARK: - this will call send message controller
        // self.chatviewmodel.chatVCDelegate?.sendMessage(conversationID: converastionID, messageID: messageID, dic: dic)
    }
    
    func didUploadMedia(_ url: StorageReference?, task: StorageUploadTask?, type: Any) {
        
        let senderID = Auth.auth().currentUser?.uid ?? ""
        var converastionID = Singleton.sharedSingleton.getOneToOneID(senderID: senderID, receiverID: userID)
        if objOppoUser.isGroup {
            converastionID = objOppoUser.uid
        }
        let db: Firestore = Firestore.firestore()
        let messageID = db.collection("Messages").document(converastionID).collection("message").document().documentID
        var dic = [String: Any]()
        dic["docId"] = messageID
        dic["messageText"] = ""
        dic["receiverId"] = userID
        dic["senderId"] = senderID
        dic["timestamp"] = Timestamp.init(date: Date())
        dic["status"] = Singleton.MessageStatus.UPLOADING
        if let type = type as? MediaType {
            
            switch type {
            case .image:
                dic["url"] = ""
                dic["message_type"] = Singleton.MessageType.IMAGE
            case .video:
                dic["url"] = ""
                dic["video_url"] = ""
                dic["message_type"] = Singleton.MessageType.VIDEO
            }
            
        } else {
            dic["message_type"] = Singleton.MessageType.TEXT
        }
        
        let message = MessageClass.init(fromDictionary: dic)
        message.task = task
        if let refURL = url {
            message.reference = refURL
        }
        Singleton.localFileUpload.append(dic)
        self.messaes.append(message)
        self.tblChat.reloadData()
        scrollToBottom()
        // MARK: - this will call send message controller
        // self.chatviewmodel.chatVCDelegate?.sendMessage(senderID: senderID, toUserID: userID, dic: dic)
        
    }
    
    func didSendMessage(_ message: Any) {
        self.tvMessage.text = ""
    }
    
    func getMessages(_ arrayMessage: Array<Any>) {
        if let array = arrayMessage as? [MessageClass] {
            if isFirstTime {
                isFirstTime = false
                self.messaes = array
            } else {
                
                for i in array {
                    
                    if i.type == .added {
                        if Singleton.MessageType.IMAGE == i.messageType || Singleton.MessageType.VIDEO == i.messageType {
                            if self.messaes.contains(where: {$0.docId == i.docId}) {
                                let index = self.messaes.firstIndex(where: {$0.docId == i.docId})
                                self.messaes[index!] = i
                            } else {
                                self.messaes.append(i)
                            }
                        } else {
                            self.messaes.append(i)
                        }
                    } else if i.type == .modified {
                        
                        if self.messaes.contains(where: {$0.docId == i.docId}) {
                            let index = self.messaes.firstIndex(where: {$0.docId == i.docId})
                            self.messaes[index!] = i
                        }
                        
                    } else if i.type == .removed {
                        self.messaes.removeAll(where: {$0.docId == i.docId})
                    }
                }
            }
        }
        
        self.tblChat.reloadData()
        scrollToBottom()
    }
    
    // MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
}

extension ChatVC: TLPhotosPickerViewControllerDelegate, CropViewControllerDelegate, croppedVideoDeleget {

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {

        cropViewController.dismiss(animated: true, completion: nil)

        let data = image.jpegData(compressionQuality: 1.0)
        var fileName = ""
        for ind in self.selectedAssets {
            fileName = ind.originalFileName ?? ""
        }

        self.chatviewmodel.chatVCDelegate?.uploadMediea(ChildPath.chatImage + fileName, file: data!, type: .image)
    }

    // TLPhotosPickerViewControllerDelegate
    func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
        // use selected order, fullresolution image
        self.selectedAssets = withTLPHAssets
        return true
    }

    func photoPickerDidCancel() {
        // cancel
    }

    func dismissComplete() {
        // picker viewcontroller dismiss completion

        for ind in self.selectedAssets {

            if ind.type == .photo || ind.type == .livePhoto {

                let cropViewController = CropViewController(croppingStyle: .default, image: ind.fullResolutionImage ?? UIImage())
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)

            } else if ind.type == .video {

                ind.exportVideoFile { URL, _ in

                    DispatchQueue.main.async {
                        let videoCropVc = VideoCropperVC(nibName: "videoCropperVC", bundle: nil)
                        videoCropVc.asset = AVAsset(url: URL)
                        videoCropVc.delegete = self
                        videoCropVc.videoURL = "\(URL)"
                        self.present(videoCropVc, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }

    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }

    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }

    func cropedVideoUrl(videoURL: String) {

        if let url = URL(string: videoURL) {

            let image = Singleton.sharedSingleton.createThumbnailOfVideoFromRemoteUrl(url: "\(url)")

            var array = [(filename: String, file: Data, type: MediaType)]()

            if let img = image {
                let data = img.jpegData(compressionQuality: 1.0)!
                let name = url.lastPathComponent.components(separatedBy: ".")[0] + ".jpeg"
                array.append((filename: ChildPath.chatImage
                              + name, file: data, type: .image))
            }

            do {
                let data = try Data(contentsOf: url)
                let filename = url.lastPathComponent
                array.append((filename: ChildPath.chatVideo
                              + filename, file: data, type: .video))
                self.chatviewmodel.chatVCDelegate?.uploadVideo(array)
            } catch {

            }
        }
    }
}
