//
//  ViewController.swift
//  Seefood
//
//  Created by Jules Lee on 17/07/2019.
//  Copyright © 2019 Jules Lee. All rights reserved.
//

import UIKit
import VisualRecognition
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topBarImageView: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    let apiKey = "FwKcj4UzxUst9MwALDil-######"
    let version = "2019-7-17"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        shareButton.isHidden = true
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func share(_ sender: Any) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title)")
            vc?.add(UIImage(named: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please login to Twitter"
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            self.imagePicker.dismiss(animated: true, completion: nil)
           
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            guard let smallImage = image.resized(withPercentage: 0.1) else { fatalError("Couldn't create small image")}
            visualRecognition.classify(image: smallImage) { (ClassifiedImages) in
                let classes = ClassifiedImages.images.first!.classifiers.first!.classes
                // reset the results before going again
                self.classificationResults = classes.map { $0.className }
                print(self.classificationResults)
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.cameraButton.isEnabled = true
                    self.shareButton.isHidden = false
                }
                
                if self.classificationResults.contains("hotdog") {
                // Best practice to bring any UI related to main thread
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.setImage(UIImage(named: "hotdog"), for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Not hotdog!"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.setImage(UIImage(named: "not-hotdog"), for: .normal)
                    }
                }
            }
        } else {
            print("There was an error picking an image")
        }
    }
    
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
