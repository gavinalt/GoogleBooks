//
//  BookDetail.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/17/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit

struct BookDetail {
    var id: String
    var selfLink: String
    
    var title: String
    var authors: String
    var publisher: String?
    var publishedDate: String?
    var description: String?
    var previewLink: String
    var infoLink: String
    
    var smallThumbnail: String
    var thumbnail: String
    
    var favourited: Bool
    
    init(from googleBook: GoogleBook) {
        id = googleBook.id
        selfLink = googleBook.selfLink
        title = googleBook.title
        authors = googleBook.authors
        publisher = googleBook.volumeInfo.publisher
        publishedDate = googleBook.volumeInfo.publishedDate
        description = googleBook.volumeInfo.description
        previewLink = googleBook.volumeInfo.previewLink
        infoLink = googleBook.volumeInfo.infoLink
        smallThumbnail = googleBook.volumeInfo.imageLinks.smallThumbnail
        thumbnail = googleBook.volumeInfo.imageLinks.thumbnail
        favourited = false
    }
    
    init(from favBooks: FavBook) {
        id = favBooks.id
        selfLink = favBooks.selfLink
        title = favBooks.title
        authors = favBooks.authors
        publisher = favBooks.publisher
        publishedDate = favBooks.publishedDate
        description = favBooks.desc
        previewLink = favBooks.previewLink
        infoLink = favBooks.infoLink
        smallThumbnail = favBooks.smallThumbnail
        thumbnail = favBooks.thumbnail
        favourited = favBooks.favourited
    }
}
