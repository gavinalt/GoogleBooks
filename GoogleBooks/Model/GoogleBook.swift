//
//  GoogleBook.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import Foundation

struct GoogleBook: Codable {
    var id: String
    var selfLink: String
    var volumeInfo: VolumeInfo
    var favourited: Bool = false
    
    var title: String {
        volumeInfo.title
    }
    var authors: String {
        volumeInfo.authors.joined(separator: ", ")
    }
}
