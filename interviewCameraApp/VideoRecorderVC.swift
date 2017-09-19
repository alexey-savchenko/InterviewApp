//
//  ViewController.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 18.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoRecorderVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {

  let captureSession = AVCaptureSession()
  var previewLayer: CALayer!
  var captureDevice: AVCaptureDevice!
  var movieOutput: AVCaptureMovieFileOutput!
  var questionQueue: [String]!



  override func viewDidLoad() {
    super.viewDidLoad()
    prepareCamera()

    
  }


  func prepareCamera() {

    captureSession.sessionPreset = AVCaptureSessionPresetHigh

    if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                              mediaType: AVMediaTypeVideo,
                                                              position: .front).devices{
      captureDevice = availableDevices.first!
      beginSession()
    }

  }

  func beginSession() {

    do {
      let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(captureDeviceInput)
      //      AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
      //      AVCaptureDeviceInput * audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
      //      [session addInput:audioInput]
      let audiodevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
      let audioinput = try AVCaptureDeviceInput(device: audiodevice)
      captureSession.addInput(audioinput)
    } catch {
      print(error.localizedDescription)
    }

    if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {

      self.previewLayer = previewLayer
      let preview = UIView()
      preview.frame = view.frame
      view.addSubview(preview)
      view.sendSubview(toBack: preview)
      preview.layer.addSublayer(self.previewLayer)

      //      view.layer.addSublayer(self.previewLayer)
      self.previewLayer.frame = preview.layer.frame
      captureSession.startRunning()

      //      let dataOutput = AVCaptureVideoDataOutput()
      //      dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber.init(value: kCVPixelFormatType_32BGRA)]
      //      dataOutput.alwaysDiscardsLateVideoFrames = true
      //
      //
      //
      //
      //      if captureSession.canAddOutput(dataOutput) {
      //
      //        captureSession.addOutput(dataOutput)
      //
      //      }
      //
      //      captureSession.commitConfiguration()
      //
      //      let queue = DispatchQueue(label: "com.svch.queue")
      //
      //      dataOutput.setSampleBufferDelegate(self, queue: queue)
      movieOutput = AVCaptureMovieFileOutput()
      if captureSession.canAddOutput(movieOutput) {
        captureSession.addOutput(movieOutput)
      }

      captureSession.commitConfiguration()

      movieOutput.startRecording(toOutputFileURL: getDocumentsDirectory().appendingPathComponent("video.mov"),
                                 recordingDelegate: self)

    }

  }

  @IBAction func buttontap(_ sender: UIButton) {
    movieOutput.stopRecording()
    do {

      print("Contents of Doc folder \(try FileManager.default.contentsOfDirectory(atPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!))")
      if FileManager.default.fileExists(atPath: getDocumentsDirectory().appendingPathComponent("video.mov").path) {

        let size = try! FileManager.default.attributesOfItem(atPath: getDocumentsDirectory().appendingPathComponent("video.mov").path)[FileAttributeKey.size] as! UInt64
        print(size)


      } else {

        print("no file")

      }
    } catch {

      print(error)

    }
  }

  func capture(_ captureOutput: AVCaptureFileOutput!,
               didStartRecordingToOutputFileAt fileURL: URL!,
               fromConnections connections: [Any]!) {
    print("22")
  }


  func capture(_ captureOutput: AVCaptureFileOutput!,
               didFinishRecordingToOutputFileAt outputFileURL: URL!,
               fromConnections connections: [Any]!, error: Error!) {
    print("23")
    let player = AVPlayer(playerItem: AVPlayerItem.init(url: URL(fileURLWithPath: getDocumentsDirectory().appendingPathComponent("video.mov").path)))
    let plContr = AVPlayerViewController()
    plContr.player = player
    self.present(plContr, animated: true) {
      print("presented")
      plContr.player?.play()
    }

  }
  
  func getDocumentsDirectory() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
}

