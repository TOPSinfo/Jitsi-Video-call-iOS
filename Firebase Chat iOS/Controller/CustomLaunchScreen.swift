//
//  CustomLaunchScreen.swift
//  SampleCodeiOS
//
//  Created by Tops on 08/10/21.
//

import UIKit

class CustomLaunchScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Will set initial viewcontroller
        Singleton.sharedSingleton.setNavigation()
    }
}
