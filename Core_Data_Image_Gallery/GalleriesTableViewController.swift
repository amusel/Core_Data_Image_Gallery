//
//  GalleriesTableViewController.swift
//  Image_Gallery
//
//  Created by Artem Musel on 9/6/19.
//  Copyright © 2019 Artem Musel. All rights reserved.
//

import UIKit
import CoreData

class GalleriesTableViewController: UITableViewController {

    private let container: NSPersistentContainer! = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Gallery> = {
        let request: NSFetchRequest<Gallery> = Gallery.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "isRemoved", ascending: false)]

        let fetchedResultsController = NSFetchedResultsController<Gallery>(
            fetchRequest: request,
            managedObjectContext: container.viewContext,
            sectionNameKeyPath: "isRemoved",
            cacheName: nil )
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? fetchedResultsController.performFetch()
        tableView.reloadData()
        
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                               action: #selector(editCell(_:)))
        tapGesture.numberOfTapsRequired = 2
        tableView.addGestureRecognizer(tapGesture)
    }
     
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    
    // MARK: - Table view data source
    let sectionTitles = ["", "Recently Deleted"]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sectionTitles[section]
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath)
        
        if let galleryCell = cell as? GalleryTableViewCell {
            galleryCell.title = fetchedResultsController.object(at: indexPath).title!
        }

        return cell
    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        let collection = GalleriesCollection.sharedInstance
//
//        if editingStyle == .delete {
//            if indexPath.section == 1 {
//                collection.deletedGalleries.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//            }
//            else if indexPath.section == 0 {
//
//                tableView.performBatchUpdates({
//                    changeStatus(forGallery: collection.availableGalleries[indexPath.row], with: true)
//
//                    //moveRows() is not used because of terrible animations it gives
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    tableView.insertRows(at: [IndexPath(row: galleriesTitles[1].count-1, section: 1)], with: .left)
//                }, completion: { _ in
//                    //update collectionView after deletion
//                    let index = IndexPath(row: self.galleriesTitles[1].count-1, section: 1)
//                    self.performSegue(withIdentifier: "ImageCollection",
//                                 sender: tableView.cellForRow(at: index))
//                })
//            }
//        }
//    }
    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        var swipeActions = UISwipeActionsConfiguration()
//        
//        if indexPath.section == 1 {
//            let restoreAction = UIContextualAction(style: .normal, title: "Restore") { (contextualAction, view, boolValue) in
//                boolValue(true)
//                
//                tableView.performBatchUpdates({
//                    self.changeStatus(forGallery: GalleriesCollection.sharedInstance.deletedGalleries[indexPath.row], with: false)
//                    
//                    let newIndexPath = IndexPath(row: self.galleriesTitles[0].count-1, section: 0)
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                    tableView.insertRows(at: [newIndexPath], with: .left)
//                    
//                    //if I remove this reload, then on last restored item strange bug appears
//                    //somehow the section title does not disapper till user makes any action
//                    tableView.reloadData()
//                })
//                
//            }
//            restoreAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
//            swipeActions = UISwipeActionsConfiguration(actions: [restoreAction])
//        }
//        
//        return swipeActions
//    }
    
    //change deleted status for gallery
//    private func changeStatus(forGallery gallery: GalleriesCollection.Gallery, with deleted: Bool) {
//        let collection = GalleriesCollection.sharedInstance
//
//        if deleted, let index = collection.availableGalleries.firstIndex(of: gallery) {
//                collection.deletedGalleries.append(collection.availableGalleries.remove(at: index))
//        }
//        else if let index = collection.deletedGalleries.firstIndex(of: gallery) {
//            collection.availableGalleries.append(collection.deletedGalleries.remove(at: index))
//        }
//    }
    
    @IBAction func addNewGallery(_ sender: UIBarButtonItem) {
        let newGallery = Gallery(context: container.viewContext)
        
        var titles = [String]()
        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            titles = fetchedObjects.map {$0.title!}
        }
        newGallery.title = "Untitled".madeUnique(withRespectTo: titles)
    }
    
    @objc func editCell(_ sender: UITapGestureRecognizer) {
        if let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)) {
            if let cell = tableView.cellForRow(at: indexPath) as? GalleryTableViewCell {
                cell.resignationHandler = { [weak self, weak cell] in
                    self?.fetchedResultsController.object(at: indexPath).title = cell!.title
                    
                    self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    self?.performSegue(withIdentifier: "ImageCollection", sender: cell)
                }
                
                cell.isEditing = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if indexPath.section == 1 {
                if let navC = segue.destination as? UINavigationController,
                    let imageCollectionView = navC.topViewController as? ImageCollectionViewController {
                    imageCollectionView.gallery = nil
                    imageCollectionView.title = ""
                }
                
                return
            }
            else if indexPath.section == 0 {
                if let navC = segue.destination as? UINavigationController,
                    let imageCollectionView = navC.topViewController as? ImageCollectionViewController {
                    imageCollectionView.gallery = fetchedResultsController.object(at: indexPath)
                    imageCollectionView.title = imageCollectionView.gallery.title
                }
            }
        }
    }
}


extension GalleriesTableViewController: NSFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            print("updates")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
