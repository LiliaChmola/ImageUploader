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
    @IBOutlet private weak var collectionView: UICollectionView!
    private lazy var  networkManager = NetworkManager()
    private var currentDateString: String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy, HH:mm"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    private var assets = [PHAsset]()
    private var selectedIndexPath = [IndexPath]()
    private var links = [NSManagedObject]()
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPHAssets()
        fetchSavedLinks()
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
    
    // MARK: - Core Data
    private func fetchSavedLinks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Link")
        
        do {
            links = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func save(url: String, date: String, image: Data, path: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Link", in: managedContext)!
        let link = NSManagedObject(entity: entity, insertInto: managedContext)
        
        link.setValue(url, forKeyPath: "url")
        link.setValue(date, forKeyPath: "date")
        link.setValue(image, forKey: "image")
        link.setValue(path, forKey: "path")
        
        links.append(link)
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
        
        // TODO: - Rewrite
        // Set uploaded style for uploaded images
        for link in links {
            if let linkPath = link.value(forKey: "path") as? String {
                assets[indexPath.row].getPath { (path) in
                    if linkPath == path {
                        cell.setUploadedStyle()
                    }
                }
            }
        }

        if selectedIndexPath.contains(indexPath) {
            cell.setUploadingStyle()
            for link in links {
                if let linkPath = link.value(forKey: "path") as? String {
                    assets[indexPath.row].getPath { (path) in
                        if linkPath == path {
                            cell.setUploadedStyle()
                        }
                    }
                }
            }
        } else {
            cell.setDefaultStyle()
        }

        return cell
    }
}

// MARK: - UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedIndexPath.contains(indexPath) {
            print("yes")
        } else {
            print("no")
            selectedIndexPath.append(indexPath)
            if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                cell.setUploadingStyle()
            }
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                let image = self.assets[indexPath.row].originalImage
                self.networkManager.post(image: image.resizedTo1MB()!, "user", completion: { [weak self] (urlString) in
                    
                    if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                        cell.setUploadedStyle()
                    }
                    if let image = self?.assets[indexPath.row].thumbnailImage { self?.assets[indexPath.row].getPath(compeletion: { (path) in
                        self?.save(url: urlString, date: self!.currentDateString, image: image.pngData()!, path: path)
                    })
                    }
                })
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        var size = CGSize.init(width: 25, height: 25)
        let orientation = UIDevice.current.orientation
        
        if orientation.isLandscape {
            size = CGSize(width: collectionView.bounds.width / 5, height: collectionView.bounds.width / 5)
        } else {
            size = CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.width / 3)
        }
        
        return size
    }
}


