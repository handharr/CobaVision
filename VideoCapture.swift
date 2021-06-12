//
//  VideoCapture.swift
//  CobaVision
//
//  Created by Puras Handharmahua on 12/06/21.
//

import Foundation
import AVFoundation
import Vision

class VideoCapture: NSObject {
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    var points: [CGPoint] = []
    
    var fingerTips: [CGPoint] = []
    
    weak var delegate: ViewController?
    
    override init() {
        super.init()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        captureSession.addInput(input)
        
        captureSession.addOutput(videoOutput)
        videoOutput.alwaysDiscardsLateVideoFrames = true
    }
    
    public func startCapture() {
        captureSession.startRunning()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoDispatchQueue"))
    }
}

extension VideoCapture: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        defer {
          DispatchQueue.main.sync {
            delegate?.processPoints(fingerTips)
          }
        }
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }
    
    private func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
        
        // Process each observation to find the recognized body pose points.
        observations.forEach { item in
            guard let recognizedPoints =
                    try? item.recognizedPoints(.all) else { return }
            
            let jointNames: [VNHumanBodyPoseObservation.JointName] = [
                .rightEye,
                .leftEye,
                .nose,
                .rightShoulder,
                .rightElbow,
                .rightWrist,
                .leftShoulder,
                .leftElbow,
                .leftWrist,
                .neck,
                .rightHip,
                .leftHip,
                .root,
                .rightKnee,
                .rightAnkle,
                .leftKnee,
                .leftAnkle
            ]
            
            fingerTips = jointNames.compactMap {
                guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
                
                return CGPoint(x: point.location.x, y: 1 - point.location.y)
            }
        }
    }
}
