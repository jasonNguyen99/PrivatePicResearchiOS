//
//  ViewController.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 07/10/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func faceDetectionButton(_ sender: Any) {
        let vc = PPFaceDetectionViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

