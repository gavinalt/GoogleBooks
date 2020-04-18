//
//  FavouriteCollectionViewController.swift
//  GoogleBooks
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import UIKit
import CoreData

class FavouriteCollectionViewController: UICollectionViewController {
    
    private var fetchedRC: NSFetchedResultsController<FavBook>!
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let reuseIdentifier = "bookCollectionCell"
    private var itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.title = "Favourited Books"
        self.collectionView!.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        collectionView.reloadData()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            itemsPerRow = 4
        } else {
            itemsPerRow = 2
        }
    }
    
    private func refresh() {
        let request = FavBook.fetchRequest() as NSFetchRequest<FavBook>
//        request.predicate = NSPredicate(format: "favourited == %@", NSNumber(value: true))
        let sort = NSSortDescriptor(key: #keyPath(FavBook.title), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.sortDescriptors = [sort]
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedRC.delegate = self
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let books = fetchedRC.fetchedObjects else { return 0 }
        return books.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell
        
        cell.deleage = self
        let curBook = fetchedRC.object(at: indexPath)
        cell.configureCell(from: BookDetail(from: curBook))
        return cell
    }
}

extension FavouriteCollectionViewController: NSFetchedResultsControllerDelegate {
    
}

extension FavouriteCollectionViewController: BookCellDelegate {
    func singleTapped(_ cell: BookCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let book = fetchedRC.object(at: indexPath)
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as? DetailViewController {
                vc.curBook = BookDetail.init(from: book)
                show(vc, sender: self)
            }
        }
    }
    
    func doubleTapped(_ cell: BookCollectionViewCell, favourited: Bool) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let fBook = fetchedRC.object(at: indexPath)
            fBook.favourited = false
            context.delete(fBook)
            appDelegate.saveContext()
            refresh()
            collectionView.reloadData()
        }
    }
}

// MARK: - Collection View Flow Layout Delegate
extension FavouriteCollectionViewController: UICollectionViewDelegateFlowLayout {
    
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
