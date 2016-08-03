//
//  ViewController.swift
//  Quick Share
//
//  Created by Grant on 26/06/2016.
//  Copyright © 2016 GK MIcro Ltd. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
    
    var imagePicker: UIImagePickerController!

    let reuseIdentifier = "tableViewCell"
    var assetCollection: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func CameraButtonClicked(_ sender: UIBarButtonItem) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "showPhotoVC") as! ShowImageViewController
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newVC.image = image
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
        show(newVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let collection = PHAssetCollection.fetchAssetCollections (with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        if (collection.firstObject != nil ) {
            self.assetCollection = collection.firstObject! as PHAssetCollection
            
            let options = PHFetchOptions()
            options.predicate = Predicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            options.sortDescriptors = [ SortDescriptor(key: "creationDate", ascending: false) ]
            
            self.photos = PHAsset.fetchAssets(in: assetCollection!, options: options)
            
        }
        else {
            print("Nothing found")
        }
        tableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            if (id == "showFullImageSegue") {
                let newVC = segue.destinationViewController as! ShowImageViewController
                
                var indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                
                if let asset = self.photos?[(indexPath?.row)!] {
                    newVC.asset = asset
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MyTableViewCell
        
        if let asset = self.photos?[indexPath.row] {

            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 320, height:    240), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                if let image = result {
                    cell.myImageView.image = image
                }
            })
        }
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = photos?.count {
            return count
        }
        return 1;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}

