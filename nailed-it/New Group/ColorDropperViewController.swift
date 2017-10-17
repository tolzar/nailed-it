//
//  ColorDropperViewController.swift
//  nailed-it
//
//  Created by Lia Zadoyan on 10/10/17.
//  Copyright © 2017 Lia Zadoyan. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationBannerSwift

class ColorDropperViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, EditColorViewControllerDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var processedView: UIImageView!
    @IBOutlet weak var targetImage: UIImageView!
    @IBOutlet weak var processedViewBorder: UIImageView!
    
    var cameraDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var colorPicked = PolishColor()
    var redValue: UInt8?
    var greenValue: UInt8?
    var blueValue: UInt8?
    var hexValue: String?
    weak var delegate: HamburgerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeTapGestures()
        
        processedViewBorder.layer.cornerRadius = 10
        processedViewBorder.clipsToBounds = true
        
        processedView.layer.cornerRadius = 10
        processedView.clipsToBounds = true

        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        
        let videoDeviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        for camera in videoDeviceDiscovery.devices as [AVCaptureDevice] {
            if camera.position == .back {
                cameraDevice = camera
            }
            if cameraDevice == nil {
                print("Could not find back camera.")
            }
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if captureSession.canAddInput(videoDeviceInput) {
                captureSession.addInput(videoDeviceInput)
            }
        } catch {
            print("Could not add camera as input: \(error)")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = cameraView.bounds
        if (previewLayer.connection?.isVideoOrientationSupported)! {
            previewLayer.connection?.videoOrientation = .portrait
        }
        cameraView.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        let videoOutputQueue = DispatchQueue(label: "VideoQueue")
        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Could not add video data as output.")
        }
        
        captureSession.startRunning()
    }
    
    func initializeTapGestures() {
        let targetTap = UITapGestureRecognizer(target: self, action: #selector(onTargetTap(tapGestureRecognizer:)))
        targetImage.isUserInteractionEnabled = true
        targetImage.addGestureRecognizer(targetTap)
        
        let processedViewTap = UITapGestureRecognizer(target: self, action: #selector(onTargetTap(tapGestureRecognizer:)))
        processedView.isUserInteractionEnabled = true
        processedView.addGestureRecognizer(processedViewTap)

    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)!
        let byteBuffer = baseAddress.assumingMemoryBound(to: UInt8.self)
                    
        let index = (((height / 2)) * width + ((width / 2))) * 4
                    
        blueValue = byteBuffer[index]
        greenValue = byteBuffer[index+1]
        redValue = byteBuffer[index+2]
        
        let color = UIColor(red: CGFloat(Double(redValue!)/255.0), green: CGFloat(Double(greenValue!)/255.0), blue: CGFloat(Double(blueValue!)/255.0), alpha: 1.0)

        hexValue = String(format:"%02X", Int(redValue!)) + String(format:"%02X", Int(greenValue!)) + String(format:"%02X", Int(blueValue!))
        
        DispatchQueue.main.async {
            self.processedView.backgroundColor = color
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
    
    @objc func onTargetTap(tapGestureRecognizer: UITapGestureRecognizer) {
        let offsetBlue = CGFloat(Int(blueValue!)) / 255
        let offsetGreen = CGFloat(Int(greenValue!)) / 255
        let offsetRed = CGFloat(Int(redValue!)) / 255
        colorPicked.blueValue = offsetBlue
        colorPicked.redValue = offsetRed
        colorPicked.greenValue = offsetGreen
        colorPicked.hexValue = hexValue
        performSegue(withIdentifier: "onColorPickedSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "onColorPickedSegue" {
            let ecvc = segue.destination as! EditColorViewController
            ecvc.polishColor = colorPicked
            ecvc.delegate = self
        }
    }
    
    @IBAction func onHamburgerPressed(_ sender: Any) {
        delegate?.hamburgerPressed()
    }
    
    func onColorSaveSuccess() {
        let banner = NotificationBanner(title: "Color successfully saved!", subtitle: "View it in the Polish Library.", style: .success)
        banner.onTap = {
            // we can do stuff here if we want
        }
        banner.show()
    }
}
