//
//  MainViewController.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/26/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit
import Photos
import CoreData

class MainViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private lazy var  networkManager = NetworkManager()
    private var currentDate: String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy, HH:mm"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    private var assets = [PHAsset]()
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPHAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    // MARK: - IBAction func
    @IBAction func linksBarButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "fromMainToLinks", sender: nil)
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
    
    private func save(url: String, date: String, image: Data) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Link", in: managedContext)!
        let link = NSManagedObject(entity: entity, insertInto: managedContext)
        
        link.setValue(url, forKeyPath: "url")
        link.setValue(date, forKeyPath: "date")
        link.setValue(image, forKey: "image")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
       
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let image = self.assets[indexPath.row].originalImage
            self.networkManager.post(image: image.resizedTo1MB()!, "user", completion: { [weak self] (urlString) in
                if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                }
                if let image = self?.assets[indexPath.row].thumbnailImage {
                    self?.save(url: urlString, date: self!.currentDate, image: image.pngData()!)
                }
            })
        }
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


