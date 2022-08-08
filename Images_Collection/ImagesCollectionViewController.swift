//
//  ViewController.swift
//  Images_Collection
//
//  Created by Мария Межова on 04.06.2022.
//

import UIKit

class ImagesCollectionViewController: UIViewController, UISearchBarDelegate {
    
    private let accessKey = "keri2rejox5uSSLArjTOP5H7aYF16Up3XGqgjifsJd4"
    
    private var results: [Result] = []
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .systemBackground
        searchBar.placeholder = "Enter your search query"
        searchBar.resignFirstResponder()
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    

    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .systemBackground
        collectionView.isUserInteractionEnabled = true
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(searchBar)
        view.addSubview(collectionView)

        let constraints = [
            
            searchBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 15),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=20&query=\(query)&client_id=\(accessKey)"
        guard let url = URL(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {return}
            do {
                let requestResults = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.results = requestResults.results
                    self?.collectionView.reloadData()
                }
            }
            
            catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            results = []
            collectionView.reloadData()
            fetchPhotos(query: text)
        }
        
    }
}


extension ImagesCollectionViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURL = self.results[indexPath.row].urls.regular
        let cell: PhotosCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as! PhotosCollectionViewCell
        cell.configure(with: imageURL)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.results.count
    }
}

extension ImagesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    private var baseInset: CGFloat { return 15 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - baseInset * 2), height: (collectionView.frame.width - baseInset * 2))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return baseInset
    }
}
