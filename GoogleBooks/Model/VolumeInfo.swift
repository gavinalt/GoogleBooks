//
//  volumeInfo.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import Foundation

struct VolumeInfo: Codable {
    var title: String
    var authors: [String]
    var publisher: String?
    var publishedDate: String?
    var description: String?
    var imageLinks: ImageLink
    var previewLink: String
    var infoLink: String
}

struct ImageLink: Codable {
    var smallThumbnail: String
    var thumbnail: String
}
