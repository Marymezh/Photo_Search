//
//  PhotoCollectionViewCell.swift
//  Images_Collection
//
//  Created by Мария Межова on 08.08.2022.
//

import Foundation
import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotosCollectionViewCell"
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    let collectionImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.backgroundColor = .systemBackground
        image.clipsToBounds = true
        image.layer.cornerRadius = 15
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(collectionImageView)
        
        let constraints = [
            collectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        collectionImageView.image = nil
    }
    
    func configure(with urlString: String, completion: @escaping (UIImage?) ->()) {
        
        utilityQueue.async {
            guard let url = URL(string: urlString) else {return}
            
            let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
                guard let self = self, let data = data, error == nil else {return}
                
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.collectionImageView.image = image
                    completion(image)
                }
            }
            
            task.resume()
        }
        
        
        
    }
}
