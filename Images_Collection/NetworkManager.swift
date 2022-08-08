//
//  NetworkManager.swift
//  Images_Collection
//
//  Created by Мария Межова on 08.08.2022.
//

import Foundation

class NetworkManager {
    
    var onDownload: (()->Void)?
    
    var results: [Result] = []
    
    private let accessKey = "keri2rejox5uSSLArjTOP5H7aYF16Up3XGqgjifsJd4"
    
    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=20&query=\(query)&client_id=\(accessKey)"
        guard let url = URL(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {return}
            do {
                let requestResults = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.results = requestResults.results
                    self.onDownload?()
                }
            }
            
            catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
}
