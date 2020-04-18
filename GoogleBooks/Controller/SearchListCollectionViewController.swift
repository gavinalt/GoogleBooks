//
//  SearchListCollectionViewController.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class SearchListCollectionViewController: UIViewController {
    
    private var fetchedRC: NSFetchedResultsController<FavBook>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let queryService = QueryService()
    
    @IBOutlet weak var noResultLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let reuseIdentifier = "bookCollectionCell"
    private var itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    
    private let maxResults = 20
    private var nextResultStartIndex = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.title = "GoogleBooks"
        
        collectionView!.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout.init()
        
        searchBar.delegate = self
        
        self.view.bringSubviewToFront(noResultLbl)
        noResultLbl.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.reloadData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            itemsPerRow = 4
        } else {
            itemsPerRow = 2
        }
    }
    
    var books: [BookDetail] = []
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func getFavBook(withId bookId: String) -> FavBook? {
        let request = FavBook.fetchRequest() as NSFetchRequest<FavBook>
        let sort = NSSortDescriptor(key: #keyPath(FavBook.title), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        request.predicate = NSPredicate(format: "id = %@", bookId)
        do {
            let searchFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            try searchFRC.performFetch()
            if let resultObjects = searchFRC.fetchedObjects {
                if resultObjects.count == 1 {
                    return resultObjects.first!
                } else if resultObjects.count > 1 {
                    print("Found (\(resultObjects.count)) match while searching for id: \(bookId)")
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func checkFavouriteStatus(forBookWithId bookId: String) -> Bool {
        if let favBook = getFavBook(withId: bookId) {
            return favBook.favourited
        } else {
            return false
        }
    }
    
    func deleteBook(withId bookId: String) -> Bool {
        if let favBook = getFavBook(withId: bookId) {
            context.delete(favBook)
            appDelegate.saveContext()
            return true
        } else {
            return false
        }
    }
}

extension SearchListCollectionViewController: BookCellDelegate {
    func singleTapped(_ cell: BookCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let book = books[indexPath.row]
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController {
                vc.curBook = book
                show(vc, sender: self)
            }
        }
    }
    
    func doubleTapped(_ cell: BookCollectionViewCell, favourited: Bool) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let bookDetail = books[indexPath.row]
            if favourited {
                let favBook = FavBook(entity: FavBook.entity(), insertInto: context)
                favBook.id = bookDetail.id
                favBook.selfLink = bookDetail.selfLink
                favBook.smallThumbnail = bookDetail.smallThumbnail
                favBook.thumbnail = bookDetail.thumbnail
                favBook.title = bookDetail.title
                favBook.authors = bookDetail.authors
                favBook.publisher = bookDetail.publisher
                favBook.publishedDate = bookDetail.publishedDate
                favBook.desc = bookDetail.description
                favBook.previewLink = bookDetail.previewLink
                favBook.infoLink = bookDetail.infoLink
                favBook.favourited = true
                appDelegate.saveContext()
            } else {
                if !deleteBook(withId: bookDetail.id) {
                    print("Can't delete book with id \(bookDetail.id)")
                }
            }
        }
    }
}

extension SearchListCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Searching"
        queryService.getSearchResults(searchTerm: searchText) { [weak self] results, errorMessage in
            
            if let results = results {
                let bookDetailArray = results.map { BookDetail(from: $0) }
                self?.books = bookDetailArray
                if results.count == 0 {
                    self?.noResultLbl.isHidden = false
                } else {
                    self?.noResultLbl.isHidden = true
                }
                self?.nextResultStartIndex = 20
                self?.collectionView.reloadData()
                self?.collectionView.setContentOffset(CGPoint.zero, animated: false)
            }
            
            if let uiview = self?.view {
                MBProgressHUD.hide(for: uiview, animated: true)
            }
            
            if !errorMessage.isEmpty {
                print("Search error: " + errorMessage)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

extension SearchListCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        
        cell.deleage = self
        var curBook = books[indexPath.row]
        curBook.favourited = checkFavouriteStatus(forBookWithId: curBook.id)
        cell.configureCell(from: curBook)
        return cell
    }
}

extension SearchListCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == books.count - 1 ) {
            guard let searchText = searchBar.text, !searchText.isEmpty else { return }
            
            // Check to see if I should load additinal pagination data
            // Not a perfect check as the num of results could be exactly 20
            // Can be improved by adding a key to record the result count
            guard books.count == nextResultStartIndex else { return }
            
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = "Loading..."
            queryService.loadMoreSearchResults(searchTerm: searchText, startIndex: nextResultStartIndex) { [weak self] results, errorMessage in
                
                if let results = results {
                    let bookDetailArray = results.map { BookDetail(from: $0) }
                    self?.books.append(contentsOf: bookDetailArray)
                    self?.nextResultStartIndex += self!.maxResults
                    self?.collectionView.reloadData()
//                    self?.collectionView.scrollToItem(at: indexPath, at: .right, animated: false)
                }
                
                if let uiview = self?.view {
                    MBProgressHUD.hide(for: uiview, animated: true)
                }
                
                if !errorMessage.isEmpty {
                    print("Search error: " + errorMessage)
                }
            }
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension SearchListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.layoutMarginsGuide.layoutFrame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem * 3 / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
