//
//  WebServices.swift
//  TheSimpsons
//
//  Created by Gavin Li on 4/3/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit

class WebServices {
    // MARK: - Class Methods
    static func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?, Bool) -> Void) {
        guard let url = URL(string: urlString) else { return closure(nil, false) }
        
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil, false)
            }
            guard response != nil else {
                print("no response")
                return closure(nil, false)
            }
            guard data != nil else {
                print("no data")
                return closure(nil, false)
            }
            
            DispatchQueue.main.async {
                if data!.count > 64 {
                    closure(UIImage(data: data!), true)
                } else {
                    closure(nil, false)
                }
            }
        }; task.resume()
    }
}
