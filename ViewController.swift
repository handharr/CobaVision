//
//  ViewController.swift
//  CobaVision
//
//  Created by Puras Handharmahua on 12/06/21.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    let videoCapture = VideoCapture()
    
    var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupVideoPreview()
    }

    private func setupVideoPreview() {
        videoCapture.startCapture()
        videoCapture.delegate = self
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else {
            return
        }
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
    }

    func processPoints(_ fingerTips: [CGPoint]) {
        
        let convertedPoints = fingerTips.map {
            previewLayer!.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        for item in fingerTips {
            let someView = UIView(frame: .init(x: 0, y: 0, width: 5, height: 5))
            someView.center = item
            someView.layer.cornerRadius = 2.5
            someView.backgroundColor = .red
            
            view.addSubview(someView)
        }
    }
}

