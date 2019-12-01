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
    @IBOutlet weak var messageView: UIView!
    private lazy var  networkManager = NetworkManager()
    private var currentDateString: String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy, HH:mm"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    private var assets = [PHAsset]()
    private var selectedIndexPathArray = [SelectedIndexPath]()
    private var links = [NSManagedObject]()
    
    // MARK: - Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorizationIfNeeded()
        fetchPHAssets()
        fetchSavedLinks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if assets.isEmpty {
            fetchPHAssets()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionViewLayout()
    }
    
    // MARK: - IBAction func
    @IBAction func linksBarButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "fromMainToLinks", sender: nil)
    }
    
    @IBAction func goToSettingsButton(_ sender: Any) {
        if let url = URL.init(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.collectionView.isHidden = false
                self?.messageView.isHidden = true
            }
        })
    }
    
    private func requestAuthorizationIfNeeded() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { [weak self] (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.messageView.isHidden = true
                        self?.fetchPHAssets()
                    } else {
                        self?.messageView.isHidden = false
                    }
                }
            }
        }
    }
    
    private func getSelectedIndexPath(for indexPath: IndexPath) -> SelectedIndexPath? {
        return selectedIndexPathArray.filter({$0.indexPath == indexPath}).first
    }
    
    private func uploadImageWith(indexPath: IndexPath) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let image = self.assets[indexPath.row].originalImage
            self.networkManager.post(image: image.resizedTo1MB()!, "user", success: { [weak self] (urlString) in
                if let selectedIndexPath = self?.getSelectedIndexPath(for: indexPath) {
                    selectedIndexPath.status = .uploaded
                }
                if let cell = self?.collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
                    cell.setUploadedStyle()
                }
                if let image = self?.assets[indexPath.row].thumbnailImage { self?.assets[indexPath.row].getPath(compeletion: { (path) in
                    self?.save(url: urlString, date: self!.currentDateString, image: image.pngData()!, path: path)
                })
                }
                }, failure: { [weak self] in
                    if let selectedIndexPath = self?.getSelectedIndexPath(for: indexPath) {
                        selectedIndexPath.status = .failure
                    }
            })
        }
    }
    
    private func isCurrentPhotoUploadedFor(indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        for link in links {
            if let linkPath = link.value(forKey: "path") as? String {
                assets[indexPath.row].getPath { (path) in
                    if linkPath == path {
                        completion(true)
                    }
                }
            }
        }
        completion(false)
    }
    
    private func showAlertWith(message: String) {
        let alertController = UIAlertController(title: "Error", message:
            message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        alertController.view.tintColor = #colorLiteral(red: 0.9921568627, green: 0.5450980392, blue: 0.5450980392, alpha: 1)
        alertController.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        alertController.view.cornerRadius = 6
        alertController.view.clipsToBounds = true
        
        self.present(alertController, animated: true, completion: nil)
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

        isCurrentPhotoUploadedFor(indexPath: indexPath) { (uploaded) in
            cell.setUploadedStyle()
        }
        
        if let selectedIndexPath = getSelectedIndexPath(for: indexPath) {
            if selectedIndexPath.status == .uploaded {
                cell.setUploadedStyle()
            } else if selectedIndexPath.status == .uploading {
                cell.setUploadingStyle()
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
    
        if let cell = collectionView.cellForItem(at: indexPath) as? MainCollectionViewCell {
            if cell.isUploaded {
                showAlertWith(message: "Image has already been uploaded")
            } else if let selectedIndexPath = getSelectedIndexPath(for: indexPath) {
                if selectedIndexPath.status == .uploaded {
                    showAlertWith(message: "Image has already been uploaded")
                } else if selectedIndexPath.status == .uploading {
                    showAlertWith(message: "Image is already loading")
                }
            } else {
                let selectedIndexPath = SelectedIndexPath(indexPath: indexPath, status: .none)
                selectedIndexPathArray.append(selectedIndexPath)
                cell.setUploadingStyle()
                uploadImageWith(indexPath: indexPath)
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


