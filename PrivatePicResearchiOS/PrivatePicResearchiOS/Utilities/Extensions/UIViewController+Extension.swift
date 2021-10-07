//
//  UIViewController+Extension.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 07/10/2021.
//

import UIKit

extension UIViewController {
    func dismissKey()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
