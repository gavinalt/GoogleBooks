//
//  DetailViewController.swift
//  TheSimpsons
//
//  Created by Gavin Li on 4/3/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    
    var curBook: BookDetail?

    @IBOutlet weak var bookImg: UIImageView!
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var bookAuthor: UILabel!
    @IBOutlet weak var bookPublisher: UILabel!
    @IBOutlet weak var bookPublishedDate: UILabel!
    @IBOutlet weak var bookDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let book = curBook {
            configureView(curBook: book)
        }
    }

    func configureView(curBook: BookDetail) {
        
        bookTitle.text = curBook.title
        bookAuthor.text = curBook.authors
        bookPublisher.text = curBook.publisher ?? ""
        bookPublishedDate.text = curBook.publishedDate ?? ""
        
        bookDescription.text = curBook.description ?? ""
        bookDescription.numberOfLines = 0
        
//        loadImage(from: curBook.thumbnail)()
        bookImg.kf.setImage(with: URL(string: curBook.thumbnail))
    }
    
    private func loadImage(from url: String) -> () -> Void {
        return { [weak self] in
            WebServices.getImageFromWeb(url) { (dlImg, _) in
                if let image = dlImg {
                    self?.bookImg.image = image
                } else {
                    self?.bookImg.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}
