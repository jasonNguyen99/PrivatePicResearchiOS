//
//  Date+Extension.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 07/10/2021.
//

import UIKit

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
