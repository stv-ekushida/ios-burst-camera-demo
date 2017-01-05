//
//  ViewController.swift
//  ios-burst-camera-demo
//
//  Created by Kushida　Eiji on 2017/01/05.
//  Copyright © 2017年 Kushida　Eiji. All rights reserved.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    
    private let session = AVCaptureSession()
    private var camera: CameraTakeable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraView(camera: BurstCameraUtil())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session.stopRunning()
        camera?.removeVideoInput(session: session)
    }
    
    private func setupCameraView(camera: CameraTakeable?) {
        
        self.camera = camera
        
        let device = camera?.findDevice(position: .back)
        camera?.createVideoDataOutput(session: session)
        
        if let videoLayer = camera?.createVideoPreviewLayer(session: session,
                                                            device: device) {            
            videoLayer.frame = baseView.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            baseView.layer.addSublayer(videoLayer)
        } else {
            fatalError("VideoLayer is Nil")
        }
    }
    
    //MARK:- Actions
    @IBAction func photoDidTapDown(_ sender: UIButton) {
        camera?.start()
    }
    
    @IBAction func photoDidTapUp(_ sender: UIButton) {
        camera?.stop()
        
        if let images = camera?.photos() {
            print("I took \(images.count) photos")
        }
    }
}
