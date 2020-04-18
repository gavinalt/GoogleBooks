import Foundation

//
// MARK: - Query Service
//

/// Runs query data task, and stores results in array of GoogleBook
class QueryService {
    //
    // MARK: - Constants
    //
    let defaultSession = URLSession(configuration: .default)
    
    //
    // MARK: - Variables And Properties
    //
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var books: [GoogleBook] = []
    
    //
    // MARK: - Type Alias
    //
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([GoogleBook]?, String) -> Void
    
    //
    // MARK: - Internal Methods
    //
    
    func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
        dataTask?.cancel()
        if var urlComponents = URLComponents(string: "https://www.googleapis.com/books/v1/volumes") {
            urlComponents.query = "q=\(searchTerm)"
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer { self?.dataTask = nil }
                
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    self?.updateSearchResults(data)
                    
                    DispatchQueue.main.async {
                        completion(self?.books, self?.errorMessage ?? "")
                    }
                }
            }
            
            dataTask?.resume()
        }
    }
    
    //
    // MARK: - Private Methods
    //
    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        books.removeAll()
        errorMessage = ""
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["items"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        
        for bookDictionary in array {
            if let bookDictionary = bookDictionary as? JSONDictionary,
                let id = bookDictionary["id"] as? String,
                let selfLink = bookDictionary["selfLink"] as? String,
                let volumeInfo = bookDictionary["volumeInfo"] as? JSONDictionary,
                let previewLinkStr = volumeInfo["previewLink"] as? String,
                let infoLinkStr = volumeInfo["infoLink"] as? String,
                let title = volumeInfo["title"] as? String {
                
                let imageLinks = volumeInfo["imageLinks"] as? JSONDictionary
                let smallThumbnailStr = (imageLinks?["smallThumbnail"] as? String) ?? ""
                let thumbnailStr = (imageLinks?["thumbnail"] as? String) ?? ""
                let imageLink = ImageLink(smallThumbnail: smallThumbnailStr, thumbnail: thumbnailStr)
                let authors = (volumeInfo["authors"] as? [String]) ?? []
                let publisher = (volumeInfo["publisher"] as? String) ?? ""
                let publishedDate = (volumeInfo["publishedDate"] as? String) ?? ""
                let description = (volumeInfo["description"] as? String) ?? ""
                
                books.append(
                    GoogleBook(id: id, selfLink: selfLink, volumeInfo:
                        VolumeInfo(title: title, authors: authors, publisher: publisher,
                                   publishedDate: publishedDate, description: description,
                                   imageLinks: imageLink, previewLink: previewLinkStr, infoLink: infoLinkStr)))
                index += 1
            } else {
                errorMessage += "Problem parsing trackDictionary\n"
            }
        }
    }
}
