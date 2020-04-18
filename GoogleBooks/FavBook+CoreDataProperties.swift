//
//  FavBook+CoreDataProperties.swift
//  
//
//  Created by Gavin Li on 4/17/20.
//
//

import Foundation
import CoreData

extension FavBook {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavBook> {
        return NSFetchRequest<FavBook>(entityName: "FavBook")
    }

    @NSManaged public var favourited: Bool
    @NSManaged public var id: String
    @NSManaged public var selfLink: String
    @NSManaged public var smallThumbnail: String
    @NSManaged public var thumbnail: String
    @NSManaged public var title: String
    @NSManaged public var authors: String
    @NSManaged public var publisher: String?
    @NSManaged public var publishedDate: String?
    @NSManaged public var desc: String?
    @NSManaged public var previewLink: String
    @NSManaged public var infoLink: String

}
