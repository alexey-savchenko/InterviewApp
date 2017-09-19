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

  enum RecordingStatus {

    case idle
    case begin
    case recording
    case finished

  }

  let captureSession = AVCaptureSession()
  var previewLayer: CALayer!
  var captureDevice: AVCaptureDevice!
  var movieOutput: AVCaptureMovieFileOutput!
  var questionQueue: [String]!
  var actionButton: CustomButton!

  var previewView: UIView!
  var overlayView: UIView!

  var status = RecordingStatus.idle {
    didSet {
      switch status {
      case .begin:

        for item in overlayView.subviews {
          item.removeFromSuperview()
        }

        let counterLabel = UILabel()
        counterLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        counterLabel.textColor = UIColor.white
        counterLabel.font = UIFont.boldSystemFont(ofSize: 50)
        counterLabel.textAlignment = .center
        overlayView.addSubview(counterLabel)
        counterLabel.center = overlayView.center

        UIView.transition(with: counterLabel,
                          duration: 0.8,
                          options: .transitionCrossDissolve,
                          animations: { 
                            counterLabel.text = "3"
        },
                          completion: { _ in
                            UIView.transition(with: counterLabel,
                                              duration: 0.8,
                                              options: .transitionCrossDissolve,
                                              animations: {
                                                counterLabel.text = "2"
                            },
                                              completion: { _ in
                                                UIView.transition(with: counterLabel,
                                                                  duration: 0.8,
                                                                  options: .transitionCrossDissolve,
                                                                  animations: {
                                                                    counterLabel.text = "1"
                                                },
                                                                  completion: { _ in
                                                                    
                                                                    UIView.animate(withDuration: 0.8, animations: { 
                                                                      self.overlayView.layer.opacity = 0
                                                                    }, completion: { _ in

                                                                      for item in self.overlayView.subviews {
                                                                        item.removeFromSuperview()
                                                                      }
                                                                      self.overlayView.removeFromSuperview()

                                                                    })
                                                })
                            })
        })

      case .recording:

        movieOutput.startRecording(toOutputFileURL: getDocumentsDirectory().appendingPathComponent("video.mov"),
                                   recordingDelegate: self)

      default:
        break
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    previewView = UIView()
    previewView.frame = view.frame
    view.addSubview(previewView)
    view.sendSubview(toBack: previewView)

    prepareCamera()

    actionButton = CustomButton(frame: CGRect.init(x: 0, y: 0, width: 150, height: 40))
    actionButton.center.x = view.center.x
    actionButton.center.y = view.bounds.height - 60
    actionButton.setTitle("Begin", for: .normal)
    actionButton.cornerRadius = 20
    actionButton.borderWidth = 1
    actionButton.borderColor = UIColor.white
    actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)

    view.addSubview(actionButton)
    view.bringSubview(toFront: actionButton)

    overlayView = UIView(frame: view.frame)
    overlayView.backgroundColor = UIColor.black
    overlayView.alpha = 0.5
    view.insertSubview(overlayView, belowSubview: actionButton)

    overlayView.addSubview({
      let label = UILabel()

      label.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 60)
      label.center = view.center
      label.textColor = UIColor.white
      label.text = "Press Begin when ready"
      label.textAlignment = .center
      label.font = UIFont.boldSystemFont(ofSize: 24)
      label.numberOfLines = 0

      return label
      }())
  }

  func actionButtonTap(){

    switch status {
    case .idle:
      status = .begin
    default:
      break
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)



  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    navigationController?.setNavigationBarHidden(true, animated: true)



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
//      let preview = UIView()
//      preview.frame = view.frame
//      view.addSubview(preview)
//      view.sendSubview(toBack: preview)
      previewView.layer.addSublayer(self.previewLayer)

      //      view.layer.addSublayer(self.previewLayer)
      self.previewLayer.frame = previewView.layer.frame
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


//MARK: Start of recording
//      movieOutput.startRecording(toOutputFileURL: getDocumentsDirectory().appendingPathComponent("video.mov"),
//                                 recordingDelegate: self)

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

