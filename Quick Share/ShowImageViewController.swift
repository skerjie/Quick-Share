//
//  ShowImageViewController.swift
//  Quick Share
//
//  Created by Grant on 27/06/2016.
//  Copyright © 2016 GK MIcro Ltd. All rights reserved.
//

import UIKit
import Photos
import Social

class ShowImageViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var asset: PHAsset?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let myAsset = asset {
            PHImageManager.default().requestImage(for: myAsset, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.width * 0.7), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
                if let image = result {
                    self.imageView.image = image
                }
            })
        } else if (image != nil) {
            self.imageView.image = image
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func Share (tag: Int) {
        
        switch tag {
        case 0:
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                ShareFacebookTwitter(vc: vc)
            }
        case 1:
            ShareInstagram()
        case 2:
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                ShareFacebookTwitter(vc: vc)
            }
        case 3:
            ShareWhatsApp()
        case 4:
            print("pin")
        case 5:
            print("fbmess")
        default:
            print("YO MR 'PRO' DEV! soemthing went wrong with your 'Share()' function")
        }
    }
    
    func ShareFacebookTwitter (vc: SLComposeViewController) {
        vc.setInitialText("Look at this great picture!")
        vc.add(imageView?.image)
        vc.add(URL(string: "https://www.learnappdevelopment.com"))
        present(vc, animated: true, completion: nil)
    }

    @IBAction func shareButtonClicked(_ sender: UIButton) {
        Share(tag: sender.tag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    var docController = UIDocumentInteractionController()
    
    func ShareInstagram() {
        
        let instagramUrl = URL(string: "instagram://app")
        if(UIApplication.shared().canOpenURL(instagramUrl!)){
            
            let imageData = UIImageJPEGRepresentation(imageView.image!, 100)
            let captionString = ""
            
            let writePath = (NSTemporaryDirectory() as NSString).appending("instagram.igo")

            do {
                    try imageData?.write (to: URL(fileURLWithPath: writePath), options: [.atomicWrite])
                    
                    let fileURL = URL(fileURLWithPath: writePath)
                    self.docController = UIDocumentInteractionController(url: fileURL)
                    self.docController.delegate = self
                    self.docController.uti = "com.instagram.exclusivegram"
                    self.docController.annotation =  NSDictionary(object: captionString, forKey: "InstagramCaption")
                    self.docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            }
            catch _ {
                print("error")
            }
        }
    }
    
    func documentsDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func ShareWhatsApp () {
        
        let urlWhats = "whatsapp://app"

            if let whatsappURL = URL(string: urlWhats) {
                
                if UIApplication.shared().canOpenURL(whatsappURL) {
                    
                    if let image = imageView.image {
                        if let imageData = UIImageJPEGRepresentation( image, 100) {

                            do {
                                let tempFile = try URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                                try imageData.write(to: tempFile, options: .atomicWrite)
                                self.docController = UIDocumentInteractionController(url: tempFile)
                                self.docController.uti = "net.whatsapp.image"
                                self.docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                } else {
                    // Cannot open whatsapp
                }
            }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

