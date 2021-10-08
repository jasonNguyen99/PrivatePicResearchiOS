//
//  PPFaceDetectionViewController.swift
//  PrivatePicResearchiOS
//
//  Created by Nguyễn Minh Hiếu on 07/10/2021.
//

import UIKit
import AVKit
import Vision
import Combine
import LocalAuthentication
import RxSwift
import ARKit
import RealityKit
import SceneKit

class PPFaceDetectionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let numberOfFaces: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .orange
        label.font = UIFont(name: "Avenir-Heavy", size: 30)
        label.text = "No face"
        return label
    }()
    
    @Published var numberOfFace : Int?
    @Published var cancelable = Set<AnyCancellable>()
    @Published var validateFaceID : Bool?

    let viewBlock = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.event()
        setupCamera()
        setupLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    func setUpUI() {
        self.viewBlock.backgroundColor = .white
        self.viewBlock.frame = self.view.frame
        self.viewBlock.isHidden = true
        let button = UIButton()
        button.setTitle("Validate Your Face", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.frame = CGRect(x: 16.0, y: self.viewBlock.center.y, width:500.0, height: 20.0)
        button.addTarget(self, action: #selector(self.buttonValidateOwnPhone), for: .touchUpInside)
        self.viewBlock.addSubview(button)
    }
    
    func event() {
        self.$numberOfFace.dropFirst().sink { _ in
        
        } receiveValue: { value in
            if value != 1 {
                self.viewBlock.isHidden = false
            }
        }.store(in: &self.cancelable)
        
        self.$validateFaceID
            .sink { _ in
            
        } receiveValue: { value in
            guard let value = value else { return }
            if value {
                DispatchQueue.main.sync {
                    self.viewBlock.isHidden = true
                }
            }
        }.store(in: &self.cancelable)

    }
    
    @objc func buttonValidateOwnPhone() {
        let reason = "Log in with Face ID"
        var context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, error in
            if success {
                self.validateFaceID = true
            } else {
                self.validateFaceID = false
            }
        }
    }
    
    
    fileprivate func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        var captureDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video,position: .front)
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice!) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        view.addSubview(self.viewBlock)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    fileprivate func setupLabel() {
        view.addSubview(numberOfFaces)
        numberOfFaces.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        numberOfFaces.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        numberOfFaces.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        numberOfFaces.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            
            if let err = err {
                print("Failed to detect faces:", err)
                return
            }
            
            DispatchQueue.main.async {
                if let results = req.results {
                    self.numberOfFace = results.count
                    self.numberOfFaces.text = "\(results.count)"
                }
            }
            
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("Failed to perform request:", reqErr)
            }
        }
        
    }
    
}

