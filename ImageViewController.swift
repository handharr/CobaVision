//
//  ImageViewController.swift
//  CobaVision
//
//  Created by Puras Handharmahua on 12/06/21.
//

import UIKit
import Vision

class ImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = UIImage(named: "push-ups")

        guard let cgImage = imageView.image?.cgImage else {return}
        
        imageView.image = UIImage(named: "push-ups")

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            return
        }
        
        // Process each observation to find the recognized body pose points.
        observations.forEach { processObservation($0) }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        
        // Retrieve all torso points.
        guard let recognizedPoints =
                try? observation.recognizedPoints(.all) else { return }
        
        // Torso joint names in a clockwise ordering.
        let torsoJointNames: [VNHumanBodyPoseObservation.JointName] = [
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
        
        // Retrieve the CGPoints containing the normalized X and Y coordinates.
        let imagePoints: [CGPoint] = torsoJointNames.compactMap {
            
            guard let point = recognizedPoints[$0], point.confidence > 0 else { return nil }
            
            guard let cgImage = imageView.image?.cgImage else {return CGPoint(x: 0, y: 0)}
            
            // Translate the point from normalized-coordinates to image coordinates.
            return VNImagePointForNormalizedPoint(point.location,
                                                  Int(cgImage.width),
                                                  Int(cgImage.height))
        }
        
        // Draw the points onscreen.
        draw(points: imagePoints)
    }
    
    private func draw(points: [CGPoint]) {
        print("Some Points ----")
        for item in points {
            print("CG Point : \(item)")
            let someView = UIView(frame: .init(x: 0, y: 0, width: 5, height: 5))
            someView.center = item
            someView.layer.cornerRadius = 2.5
            someView.backgroundColor = .red
            
            view.addSubview(someView)
        }
        print("End Some Points ---\n")
    }
}
