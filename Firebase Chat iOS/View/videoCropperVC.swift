//
//  videoCropperVC.swift
//  Quirktastic
//
//  Created by Tops on 03/06/19.
//  Copyright © 2019 tops. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import ICGVideoTrimmer

// MARK: - protocols

protocol croppedVideoDeleget {
    func cropedVideoUrl(videoURL:String)
}

class videoCropperVC: UIViewController {
    
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    @IBOutlet weak var btn_PlayPause: UIButton!
    @IBOutlet weak var lbl_palyPause : UILabel!
    @IBOutlet weak var videoSeekBar: UISlider!
    @IBOutlet weak var lbl_remainingTime: UILabel!
    @IBOutlet weak var lbl_selectedTime: UILabel!
    
    // MARK: - Variables
    
    var icgtrimmerview = ICGVideoTrimmerView()
    var asset : AVAsset!
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var videoURL : String!
    var delegete : croppedVideoDeleget?
    var maxLength = 15
    var startTime : CGFloat?
    var endTime : CGFloat?
    
    
    // MARK: - Loadview
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.layoutSubviews()
        DispatchQueue.main.async {
            
            self.addVideoPlayer(with: self.asset, playerView: self.playerView)
            
            let global = UIScreen.main.bounds
            if #available(iOS 11.0, *) {
                self.icgtrimmerview.frame = self.trimmerView.frame
            } else {
                self.icgtrimmerview.frame = CGRect(x: 0, y: global.height-((global.height*0.15 + 20)), width: global.width, height: global.height*0.15)
            }
            
            self.icgtrimmerview.themeColor = UIColor(named: "ic_app_bar_color")
            self.icgtrimmerview.asset = self.asset
            self.icgtrimmerview.showsRulerView = false
            self.icgtrimmerview.minLength = 3
            self.icgtrimmerview.thumbWidth = 20
            self.icgtrimmerview.trackerColor = UIColor.black
            self.icgtrimmerview.tintColor = .clear
            self.icgtrimmerview.maxLength = CGFloat(self.maxLength)
            self.icgtrimmerview.delegate = self
            self.icgtrimmerview.resetSubviews()
            self.startTime = 0
            
            if CGFloat(self.asset.duration.seconds) > 15
            {
                self.endTime = 15.0
            }
            else
            {
                self.endTime = CGFloat(self.asset.duration.seconds)
            }
            
            self.view.addSubview(self.icgtrimmerview)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func btnBackTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func btnPlayPauseTapped(_ sender: UIButton) {
        
        guard let player = player else { return }
        // button_play
        if !player.isPlaying {
            player.play()
            sender.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            lbl_palyPause.text = "Pause"
            startPlaybackTimeChecker()
        } else {
            player.pause()
            sender.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
            lbl_palyPause.text = "Play"
            stopPlaybackTimeChecker()
        }
        
    }
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        
        
        if let url = URL(string: videoURL ?? "")
        {
            let asset = AVAsset(url: url)
            
            let duration = asset.duration
            let durationTime = CMTimeGetSeconds(duration)
            print(durationTime)
            if durationTime < 3
            {
                Singleton.sharedSingleton.showToast(message: "Video should be of minimum 3 seconds")
                return
            }
            
        }
        
        if let url = NSURL(string: videoURL){
            self.cropVideo(sourceURL1: url, statTime: Float(startTime ?? 0.0), endTime: Float(endTime ?? 0.0))
        }
        
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        stopPlaybackTimeChecker()
        
        DispatchQueue.main.async {
            let playerTime = CMTimeMakeWithSeconds(Float64(self.startTime!), preferredTimescale: 1000)
            self.player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            print("current Time", CMTimeGetSeconds((self.player?.currentTime())!))
            self.icgtrimmerview.seek(toTime: self.startTime!)
            self.btn_PlayPause.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
            self.lbl_palyPause.text = "Play"
        }
    }
    
    func startPlaybackTimeChecker() {
        print("current Time", CMTimeGetSeconds((player?.currentTime())!))
        stopPlaybackTimeChecker()
        counter = 0
        self.videoSeekBar.value = 0
        self.lbl_remainingTime.text = String(format: "%02d:%02d", 0,counter)
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                                        selector:
                                                            #selector(self.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    var counter = 0
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = startTime, let endTime = endTime, let player = player else {
            return
        }
        
        let curTime = player.currentTime()
        var seconds = CMTimeGetSeconds(curTime)
        if seconds < 0 {
            seconds = Float64(0) // this happens! dont know why.
        }
        self.icgtrimmerview.seek(toTime: CGFloat(seconds))
        
        let playBackTime = player.currentTime()
        counter += 1
        self.videoSeekBar.value += 1.0
        
        if playBackTime >= CMTimeMakeWithSeconds(Float64(endTime), preferredTimescale: 1000) {
            player.pause()
            player.seek(to:  CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: 1000), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            self.videoSeekBar.value = 0
            btn_PlayPause.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
            lbl_palyPause.text = "Play"
            counter = 0
        }
        self.lbl_remainingTime.text = String(format: "%02d:%02d", 0,counter)
    }
    
    @IBAction func seekSlidervalue(_ sender: UISlider) {
        counter = Int(videoSeekBar.value)
        self.lbl_remainingTime.text = String(format: "%02d:%02d", 0,counter)
        
        let playerTime = CMTime(seconds: Double((startTime ?? 0.0) + CGFloat(sender.value)), preferredTimescale: 1000)
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        btn_PlayPause.setImage(#imageLiteral(resourceName: "pauseBtn"), for: .normal)
        startPlaybackTimeChecker()
        
    }
    
    
    func cropVideo(sourceURL1: NSURL, statTime:Float, endTime:Float)
    {
        let manager = FileManager.default
        
        if player!.isPlaying
        {
            player!.pause()
            btn_PlayPause.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
            lbl_palyPause.text = "Play"
            stopPlaybackTimeChecker()
        }
        
        Singleton.sharedSingleton.showLoder()
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let mediaType = "mp4" // as? String else { return }
        let url = sourceURL1 // as? NSURL else { return }
        
        if mediaType == kUTTypeMovie as String || mediaType == "mp4" as String {
            let asset = AVAsset(url: url as URL)
            let length = Float(asset.duration.value) / Float(asset.duration.timescale)
            print("video length: \(length) seconds")
            
            let start = statTime
            let end = endTime
            
            var outputURL = documentDirectory.appendingPathComponent("output")
            do {
                try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                let name = "\(NSDate().timeIntervalSince1970)"
                outputURL = outputURL.appendingPathComponent("\(name).mp4")
            }catch let error {
                print(error)
            }
            
            // Remove existing file
            _ = try? manager.removeItem(at: outputURL)
            
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(start), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(end), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    
                    DispatchQueue.main.async {
                        Singleton.sharedSingleton.hideLoader()
                        self.delegete?.cropedVideoUrl(videoURL: "\(outputURL)")
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                case .failed:
                    Singleton.sharedSingleton.hideLoader()
                case .cancelled:
                    Singleton.sharedSingleton.hideLoader()
                default:
                    Singleton.sharedSingleton.hideLoader()
                    break
                }
            }
        }
    }
}

extension videoCropperVC: ICGVideoTrimmerDelegate {
    
    func trimmerView(_ trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        
        self.startTime = startTime
        self.endTime = endTime
        let playerTime = CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: 1000)
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.pause()
        btn_PlayPause.setImage(#imageLiteral(resourceName: "button_play"), for: .normal)
        lbl_palyPause.text = "Play"
        let (_,sm,ss) = secondsToHoursMinutesSeconds(seconds: Int(startTime.rounded()))
        let (_,em,es) = secondsToHoursMinutesSeconds(seconds: Int(endTime.rounded()))
        
        let duration = Int(self.endTime!.rounded() - self.startTime!.rounded())
        self.videoSeekBar.value = 0//Float(Int(self.startTime!.rounded()))
        self.videoSeekBar.minimumValue = 0//Float(Int(self.startTime!.rounded()))
        self.videoSeekBar.maximumValue = Float(duration)
        self.lbl_selectedTime.text = String(format: "%02d:%02d - %02d:%02d", sm,ss,em,es)
        print(duration)
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
}

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
}
