//
//  BookCollectionViewCell.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit

protocol BookCellDelegate: class {
    func singleTapped(_ cell: BookCollectionViewCell)
    func doubleTapped(_ cell: BookCollectionViewCell, favourited: Bool)
}

class BookCollectionViewCell: UICollectionViewCell {
    
    var thisBook: BookDetail!
    
    var cellTitleLbl: UILabel!
    var cellAuthorLbl: UILabel!
    var cellImageView: UIImageView!
    var cellFavIcon: UIImageView!
    
    weak var deleage: BookCellDelegate?
    
    var singleTap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped(_:)))
        singleTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTap)
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        singleTap.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func singleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            deleage?.singleTapped(self)
        }
    }
    
    @objc private func doubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .ended {
            guard thisBook != nil else { return }
            thisBook.favourited = !thisBook.favourited
            setupFavIcon(favourited: thisBook.favourited)
            deleage?.doubleTapped(self, favourited: thisBook.favourited)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellTitleLbl?.text = ""
        cellAuthorLbl?.text = ""
        cellImageView?.image = UIImage(named: "placeholder")
    }
    
    func setupFavIcon(favourited: Bool) {
        cellFavIcon?.removeFromSuperview()
        
        let iconConfig = UIImage.SymbolConfiguration(scale: .large)
        var icon: UIImage?
        if favourited {
            let favIcon = UIImage(systemName: "heart.fill", withConfiguration: iconConfig)
            icon = favIcon?.withTintColor(.red, renderingMode: .alwaysOriginal)
        } else {
            let unFavIcon = UIImage(systemName: "heart", withConfiguration: iconConfig)
            icon = unFavIcon?.withTintColor(.blue, renderingMode: .alwaysOriginal)
        }
        let iconView = UIImageView(image: icon)
        self.addSubview(iconView)
        cellFavIcon = iconView
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
        iconView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 4).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: iconView.image!.size.width).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: iconView.image!.size.height).isActive = true
    }
    
    func configureCell(from bookDetail: BookDetail) {
        thisBook = bookDetail
        if cellTitleLbl == nil || cellAuthorLbl == nil || cellImageView == nil {
            cellTitleLbl?.removeFromSuperview()
            cellAuthorLbl?.removeFromSuperview()
            cellImageView?.removeFromSuperview()
            
            let cTitleLbl = { () -> UILabel in
                let label = UILabel()
                label.numberOfLines = 2
                label.lineBreakMode = .byTruncatingTail
                label.font = UIFont(name: "HelveticaNeue", size: 12)
                label.textColor = .black
                label.textAlignment = .left
                label.translatesAutoresizingMaskIntoConstraints = false
                return label
            }
            let titleLbl = cTitleLbl()
            let authorLbl = cTitleLbl()
            authorLbl.textColor = .gray
            let imageView: UIImageView = {
                let img = UIImageView()
                img.contentMode = .scaleAspectFit
                img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
                img.layer.cornerRadius = 5
                img.clipsToBounds = true
                return img
            }()
            
            self.contentView.addSubview(titleLbl)
            self.contentView.addSubview(authorLbl)
            self.contentView.addSubview(imageView)
            cellTitleLbl = titleLbl
            cellAuthorLbl = authorLbl
            cellImageView = imageView
            
            titleLbl.isUserInteractionEnabled = true
            
            imageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            
            titleLbl.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2).isActive = true
            titleLbl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            titleLbl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            
            authorLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 0).isActive = true
            authorLbl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            authorLbl.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            authorLbl.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        }
        
        cellTitleLbl.text = bookDetail.title
        cellAuthorLbl.text = bookDetail.authors
        
        loadImage(from: bookDetail.smallThumbnail)()
        
        setupFavIcon(favourited: bookDetail.favourited)
    }
    
    private func loadImage(from url: String) -> () -> Void {
        return { [weak self] in
            WebServices.getImageFromWeb(url) { (dlImg, _) in
                if let image = dlImg {
                    self?.cellImageView?.image = image
                } else {
                    self?.cellImageView?.image = UIImage(named: "placeholder")
                }
            }
        }
    }
}

extension BookCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.singleTap &&
            otherGestureRecognizer == self.doubleTap {
            return true
        }
        return false
    }
}
