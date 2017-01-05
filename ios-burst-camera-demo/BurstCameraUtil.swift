//
//  BurstCameraUtil.swift
//  ios-burst-camera-demo
//
//  Created by Kushida　Eiji on 2017/01/05.
//  Copyright © 2017年 Kushida　Eiji. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraTakeable {
    
    func findDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice?
    func createVideoPreviewLayer(session: AVCaptureSession?,
                            device: AVCaptureDevice?) -> AVCaptureVideoPreviewLayer?
    func createVideoDataOutput(session: AVCaptureSession?)
    func removeVideoInput(session: AVCaptureSession?)
    func start()
    func stop()
    func photos() -> [UIImage]
}

final class BurstCameraUtil: NSObject {
    
    fileprivate var images:[UIImage] = []
    fileprivate var isShooting = false
    fileprivate var counter = 0
    
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    func findDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        let device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera,
                                                   mediaType: AVMediaTypeVideo,
                                                   position: position)
        
        device?.activeVideoMinFrameDuration = CMTimeMake(1, 30)
        return device
    }
    
    func createVideoPreviewLayer(session: AVCaptureSession?,
                            device: AVCaptureDevice?) -> AVCaptureVideoPreviewLayer?{
        
        let videoInput = try! AVCaptureDeviceInput.init(device: device)
        
        if (session?.canAddInput(videoInput))! {
            session?.addInput(videoInput)
        }
        
        if (session?.canAddOutput(photoOutput))! {
            session?.addOutput(photoOutput)
        }
        
        return AVCaptureVideoPreviewLayer.init(session: session)
    }
    
    func removeVideoInput(session: AVCaptureSession?) {
        
        if let inputs = session?.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                session?.removeInput(input)
            }
        }
    }
    
    func createVideoDataOutput(session: AVCaptureSession?) {
        
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        session?.addOutput(videoDataOutput)
        session?.sessionPreset = AVCaptureSessionPreset1920x1080
    }
    
    func start() {
        images = []
        isShooting = true
    }
    
    func stop() {
        isShooting = false
    }
    
    func photos() -> [UIImage] {
        return images
    }
}

extension BurstCameraUtil: CameraTakeable {}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension BurstCameraUtil: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        
        if counter % 3 == 0 { // 1/10秒だけ処理する
            if isShooting {
                let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer)
                images.append(image)
            }
        }
        counter += 1
    }
    
    private func imageFromSampleBuffer(sampleBuffer :CMSampleBuffer) -> UIImage {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        CVPixelBufferLockBaseAddress(imageBuffer,
                                     CVPixelBufferLockFlags(rawValue: 0))
        
        let base = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)!
        let bytesPerRow = UInt(CVPixelBufferGetBytesPerRow(imageBuffer))
        let width = UInt(CVPixelBufferGetWidth(imageBuffer))
        let height = UInt(CVPixelBufferGetHeight(imageBuffer))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue) as UInt32)
        let newContext = CGContext(data: base,
                                   width: Int(width),
                                   height: Int(height),
                                   bitsPerComponent: Int(bitsPerCompornent),
                                   bytesPerRow: Int(bytesPerRow),
                                   space: colorSpace,
                                   bitmapInfo: bitmapInfo.rawValue)! as CGContext
        
        let imageRef = newContext.makeImage()!
        let image = UIImage(cgImage: imageRef,
                            scale: 1.0,
                            orientation: UIImageOrientation.right)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer,
                                       CVPixelBufferLockFlags(rawValue: 0))
        return image
    }
}
