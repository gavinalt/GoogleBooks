//
//  GoogleBooksTests.swift
//  GoogleBooksTests
//
//  Created by Gavin Li on 4/14/20.
//  Copyright © 2020 Gavin Li. All rights reserved.
//

import XCTest
@testable import GoogleBooks

class GoogleBooksTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGoogeBook() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let testGB = GoogleBook(id: "", selfLink: "", volumeInfo: VolumeInfo(title: "", authors: ["testa", "testb"], publisher: nil, publishedDate: nil, description: nil, imageLinks: ImageLink(smallThumbnail: "", thumbnail: ""), previewLink: "", infoLink: ""))
        XCTAssertEqual(testGB.authors, "testa, testb", "GoogleBook.authors computed properties doesn't work!")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
