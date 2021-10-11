//
//  PPBlockScreenShotViewController.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 08/10/2021.
//

import UIKit
import RxSwift
import RxCocoa
import Combine
import Photos

class PPBlockScreenShotViewController: UIViewController {

    let disposeBag = DisposeBag()
    let screenProtector = ScreenProtector()
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.makeSecure()
        NotificationCenter
            .default
            .rx
            .notification(UIApplication.userDidTakeScreenshotNotification, object: nil)
            .subscribe { _ in
                self.fetchPhotos()
                UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0)
                        guard let context = UIGraphicsGetCurrentContext() else { return }
                self.view.layer.render(in: context)
                        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
                        UIGraphicsEndImageContext()
                        
                        //Save it to the camera roll
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                self.detectScreenShot()
            } onError: { _ in

            } onCompleted: {

            } onDisposed: {

            }.disposed(by: self.disposeBag)
    }
    
    func fetchPhotos () {
            // Sort the images by descending creation date and fetch the first 3
            let fetchOptions = PHFetchOptions()
                    //Print out all library Photos
            let library = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            print("Total Media Photos: \(library.count)")
            
                    //Potentially Fetching the Image Based on the Screenshot identifier.
            fetchOptions.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
            
                //Fetching Screen Shots
            let result2 = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(result2.lastObject)
        }, completionHandler: {
                success, error in
            
        })
//            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0)
//            guard let context = UIGraphicsGetCurrentContext() else { return }
//            self.view.layer.render(in: context)
//            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
//            UIGraphicsEndImageContext()
//
//            //Save it to the camera roll
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//            print("Screenshots: \(result2.count) :: 2")
        }
    
    func detectScreenShot() {
        var fetchOptions: PHFetchOptions = PHFetchOptions()

        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        var fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

        if (fetchResult.lastObject != nil) {

            var lastAsset: PHAsset = fetchResult.lastObject! as PHAsset

            let arrayToDelete = NSArray(object: lastAsset)
            
            
                        var assetResultsF = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
                        PHImageManager.default().requestImageDataAndOrientation(for: lastAsset, options: nil,
                                resultHandler: { (imagedata, dataUTI, orientation, info) in
                                    if let imageSource = CGImageSourceCreateWithData(imagedata! as CFData, nil) {
                                        let uti: CFString = CGImageSourceGetType(imageSource)!
                                        let dataWithEXIF: NSMutableData = NSMutableData(data: imagedata!)
                                        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

                                        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary

                                        let mutable: NSMutableDictionary = imageProperties.mutableCopy() as! NSMutableDictionary

                                        let EXIFDictionary: NSMutableDictionary = (mutable[kCGImagePropertyExifDictionary as String] as? NSMutableDictionary)!

                                        EXIFDictionary[kCGImagePropertyExifUserComment as String] = "type:photo"

                                        mutable[kCGImagePropertyExifDictionary as String] = EXIFDictionary

                                        CGImageDestinationAddImageFromSource(destination, imageSource, 0, (mutable as CFDictionary))
                                        CGImageDestinationFinalize(destination)

                                    }
                                })
            PHPhotoLibrary.shared().performChanges({
                
            }, completionHandler: {
                    success, error in
                
            })
        }
    }

}

class ScreenProtector {
    private var warningWindow: UIWindow?

    private var window: UIWindow? {
        return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
    }

    func startPreventingRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectRecording), name: UIScreen.capturedDidChangeNotification, object: nil)
    }

    func startPreventingScreenshot() {
        NotificationCenter.default.addObserver(self, selector: #selector(didDetectScreenshot), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }

    @objc private func didDetectRecording() {
        DispatchQueue.main.async {
            self.hideScreen()
            self.presentwarningWindow("Screen recording is not allowed in our app!")
        }
    }

    @objc private func didDetectScreenshot() {
        DispatchQueue.main.async {
            self.hideScreen()
            self.presentwarningWindow( "Screenshots are not allowed in our app. Please follow the instruction to delete the screenshot from your photo album!")
    //        self.grandAccessAndDeleteTheLastPhoto()
        }
    }

    private func hideScreen() {
        if UIScreen.main.isCaptured {
            window?.isHidden = true
        } else {
            window?.isHidden = false
        }
    }

    func presentwarningWindow(_ message: String) {
        // Remove exsiting
        warningWindow?.removeFromSuperview()
        warningWindow = nil

        guard let frame = window?.bounds else { return }

        // Warning label
        let label = UILabel(frame: frame)
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = message

        // warning window
        var warningWindow = UIWindow(frame: frame)

        let windowScene = UIApplication.shared
            .connectedScenes
            .first {
                $0.activationState == .foregroundActive
            }
        if let windowScene = windowScene as? UIWindowScene {
            warningWindow = UIWindow(windowScene: windowScene)
        }

        warningWindow.frame = frame
        warningWindow.backgroundColor = .black
        warningWindow.windowLevel = UIWindow.Level.statusBar + 1
        warningWindow.clipsToBounds = true
        warningWindow.isHidden = false
        warningWindow.addSubview(label)

        self.warningWindow = warningWindow

        UIView.animate(withDuration: 0.15) {
            label.alpha = 1.0
            label.transform = .identity
        }
        warningWindow.makeKeyAndVisible()
    }

    // MARK: - Deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension PHAsset {

func updateChanges(with img:UIImage,completion:@escaping(PHAsset?)->()){

    PHPhotoLibrary.shared().performChanges({
        // create cropped image into phphotolibrary
        PHAssetChangeRequest.creationRequestForAsset(from: img)
    }) { (success, error) in
        if success{
            // fetch request to get last created asset
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
            fetchOptions.fetchLimit = 1
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)

            if let asset = fetchResult.firstObject{
                // replace your selected asset with new cropped one
                completion(asset)
            }else{
                completion(nil)
            }

        }else{
            completion(nil)
        }
    }

}
}

extension UIView {
    func makeSecure() {
        DispatchQueue.main.async {
            let field = UITextField()
            field.isSecureTextEntry = true
            self.addSubview(field)
            field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.layer.superlayer?.addSublayer(field.layer)
            field.layer.sublayers?.first?.addSublayer(self.layer)
        }
    }
}
