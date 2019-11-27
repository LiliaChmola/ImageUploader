//
//  MainViewController.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/26/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var  networkManager = NetworkManager()
    private var assets = [PHAsset]()
    private var links = [String]()
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPHAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
         updateCollectionViewLayout()
    }
    
    // MARK: - Private funcs
    
    private func updateCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.prepare()
            layout.invalidateLayout()
        }
    }
    
    private func fetchPHAssets() {
        let options = PHFetchOptions.init()
        
        let fetchAssets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        
        fetchAssets.enumerateObjects({ [weak self] (asset, _, _) in
            self?.assets.append(asset)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as? MainCollectionViewCell else { return UICollectionViewCell() }
        cell.imageView.image = assets[indexPath.row].thumbnailImage
        cell.activityIndicator.isHidden = true
        
        return cell
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = assets[indexPath.row].originalImage
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
            cell.activityIndicator.startAnimating()
            cell.activityIndicator.isHidden = false
        }
        
        networkManager.post(image: image.resizedTo1MB()!, "user", completion: { [weak self] (link) in
            if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                self?.links.append(link)
                print(self?.links.count)
            }
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize.init(width: 25, height: 25)
        let orientation = UIDevice.current.orientation

        if orientation.isPortrait {
            size = CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.width / 3)
        } else if orientation.isLandscape {
            size = CGSize(width: collectionView.bounds.width / 5, height: collectionView.bounds.width / 5)
        }
        
        return size
    }
}


