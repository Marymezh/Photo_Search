//
//  ViewController.swift
//  Images_Collection
//
//  Created by Мария Межова on 04.06.2022.
//

import UIKit

class ImagesCollectionViewController: UIViewController, UISearchBarDelegate {
    
    private let networker = NetworkManager()
    
    private let cache = NSCache<NSNumber, UIImage>()
    
    
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            networker.results = []
            self.cache.removeAllObjects()
            networker.onDownload = {[weak self] in
                guard let self = self else {return}
                self.collectionView.reloadData()
            }
            networker.fetchPhotos(query: text)
        }
    }
}


extension ImagesCollectionViewController: UICollectionViewDataSource {
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageURL = networker.results[indexPath.row].urls.regular
        let cell: PhotosCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifier, for: indexPath) as! PhotosCollectionViewCell
         let itemNumber = NSNumber(value: indexPath.item)
         
         if let cachedImage = self.cache.object(forKey: itemNumber) {
             print ("Using a cached image for item: \(itemNumber)")
             cell.collectionImageView.image = cachedImage
             
         } else {
             
             cell.configure(with: imageURL) { [weak self] (image) in
                 guard let self = self, let image = image else {return}
                 cell.collectionImageView.image = image
                 self.cache.setObject(image, forKey: itemNumber)
             }
         }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return networker.results.count
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
