//
//  PPBlockScreenShotViewController.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 08/10/2021.
//

import UIKit
import RxSwift
import RxCocoa

class PPBlockScreenShotViewController: UIViewController {

    let disposeBag = DisposeBag()
    let screenProtector = ScreenProtector()
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.rx.addObserver(
//            forName: UIApplication.userDidTakeScreenshotNotification,
//            object: nil,
//            queue: .main) { notification in
//                let view = UIView()
//                view.bounds = CGRect(x: 0.0, y: 0.0, width: 100, height: 200)
//                view.backgroundColor = .blue
//                self.view.addSubview(view)
//                print("screen shot")
//            }
//        NotificationCenter
//            .default
//            .rx
//            .notification(UIApplication.userDidTakeScreenshotNotification, object: nil)
//            .subscribe { _ in
//                DispatchQueue.main.async {
//                    self.screenProtector.hideScreen()
//                    self.screenProtector.presentwarningWindow()
////                    self.screenProtector.grandAccessAndDeleteTheLastPhoto()
//                    }
//            } onError: { _ in
//                
//            } onCompleted: {
//                
//            } onDisposed: {
//                
//            }.disposed(by: self.disposeBag)

        
//        let image = UIScene
        
//        NotificationCenter.default.addObserver(
//            forName: UIApplication.,
//            object: nil,
//            queue: .main) { notification in
//                let view = UIView()
//                view.bounds = CGRect(x: 0.0, y: 0.0, width: 100, height: 200)
//                view.backgroundColor = .blue
//                self.view.addSubview(view)
//                print("screen shot")
//            }
    }
    
    func detectScreenShot() {
        
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
