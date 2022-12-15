//
//  Extensions.swift
//  SampleCodeiOS
//
//  Created by Tops on 01/10/21.
//

import Foundation
import UIKit
import Nuke

// MARK: - To Conver date into milliseconds
extension Date {
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}

// MARK: - To elivate extra property of UIView
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            
            if newValue == 1
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                    self.layer.cornerRadius = self.frame.size.height/2
                }
                
                DispatchQueue.main.async {
                     self.layer.cornerRadius = self.frame.size.height/2
                }
            }
            else
            {
                layer.cornerRadius = newValue
            }
            
        }
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor1: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
}

extension UIImageView {
    
    func setUserImageUsingUrl(_ imageUrl: String?,isUser:Bool){
            
        if imageUrl?.isEmpty == false {
            let options = ImageLoadingOptions(
                placeholder: isUser ? #imageLiteral(resourceName: "ic_user"):#imageLiteral(resourceName: "ic_placeholder"),
                transition: .fadeIn(duration: 0.33)
            )
            Nuke.loadImage(with: URL(string: imageUrl ?? "")!, options: options, into: self)
        } else {
            self.image = isUser ? #imageLiteral(resourceName: "ic_user"):#imageLiteral(resourceName: "ic_placeholder")
        }
    }
    
}
