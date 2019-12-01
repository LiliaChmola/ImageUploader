//
//  LinksViewController.swift
//  Image Uploader
//
//  Created by Chmola Lilia on 11/28/19.
//  Copyright © 2019 Lilia Chmola. All rights reserved.
//

import UIKit
import CoreData
import SafariServices

class LinksViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var messageView: UIView!
    private var links = [NSManagedObject]()
    
    // MARK: - Controller lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Link")
        
        do {
            links = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        messageView.isHidden = !links.isEmpty
    }
}

// MARK: - UITableViewDataSource
extension LinksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LinkTableViewCell", for: indexPath) as? LinkTableViewCell else { return UITableViewCell() }
        let link = links[indexPath.row]
        cell.linkLabel.text = link.value(forKey: "url") as? String
        cell.dateLabel.text = link.value(forKey: "date") as? String
        if let imageData = link.value(forKey: "image") as? Data {
            cell.previewImageView.image = UIImage.init(data: imageData)
            cell.previewImageView.cornerRadius = cell.previewImageView.bounds.width / 2
            cell.previewImageView.clipsToBounds = true
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LinksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let urlString = links[indexPath.row].value(forKey: "url") as? String {
            if let url = URL(string: urlString) {
                let svc = SFSafariViewController(url: url)
                svc.preferredControlTintColor = #colorLiteral(red: 0.9921568627, green: 0.5450980392, blue: 0.5450980392, alpha: 1)
                present(svc, animated: true, completion: nil)
            }
        }
    }
}

