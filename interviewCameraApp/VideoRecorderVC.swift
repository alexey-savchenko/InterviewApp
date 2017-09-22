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
import Photos

class VideoRecorderVC: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
  
  enum RecordingStatus {
    
    case idle
    case begin
    case recording
    case finished
    
  }
  
  var timer: Timer!
  var timeElapsedSeconds = 0
  var answerTimeWaypoints = [Int]()
  
  let captureSession = AVCaptureSession()
  var previewLayer: CALayer!
  var captureDevice: AVCaptureDevice!
  var movieOutput: AVCaptureMovieFileOutput!
  
  var questionQueue: [String]!
  var currentQuestionIndex = 0 {
    
    didSet{
      
      if currentQuestionIndex == (questionQueue.count - 1) {
        
        UIView.animate(withDuration: 0.5, animations: {
          self.nextButton.layer.opacity = 0
        }, completion: { (_) in
          UIView.animate(withDuration: 0.5, animations: {
            self.actionButton.layer.opacity = 1
            self.actionButton.setTitle("Finish", for: .normal)
            
          })
        })
        
      }
      
    }
    
  }
  
  var actionButton: CustomButton!
  var nextButton: CustomButton!
  
  var previewView: UIView!
  var overlayView: UIView!
  var questionOverlayView: UIView!
  var questionLabel: UILabel!
  
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
                                                                      self.status = .recording
                                                                      
                                                                    })
                                                })
                            })
        })
        
      case .recording:
        
        if questionQueue.count > 1 {

          UIView.animate(withDuration: 0.5, animations: {
            self.actionButton.layer.opacity = 0
          }, completion: { (_) in
            self.nextButton.layer.opacity = 1
          })

        } else {

          self.actionButton.setTitle("Finish", for: .normal)
        }
        
        FileManager.default.checkFileAndDeleteAtURL(FileManager.default.getDocumentsDirectory().appendingPathComponent("video.mov"),
                                                    completion: {
                                                      self.movieOutput.startRecording(toOutputFileURL: FileManager.default.getDocumentsDirectory().appendingPathComponent("video.mov"),
                                                                                      recordingDelegate: self)
        })
        
        UIView.animate(withDuration: 0.5, animations: {
          self.questionOverlayView.layer.opacity = 0.5
        }, completion: { (_) in
          self.setQuestionWithIndex(0)
        })
        
      case .finished:
        print(answerTimeWaypoints)
        movieOutput.stopRecording()
        
        //Hide action button
        self.actionButton.layer.opacity = 0
        
        let activityContainer = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityContainer.center = view.center
        activityContainer.backgroundColor = UIColor.black
        activityContainer.alpha = 0.5
        activityContainer.layer.cornerRadius = 10
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.frame = activityContainer.bounds
        activityContainer.addSubview(activity)
        
        view.addSubview(activityContainer)
        questionOverlayView.removeFromSuperview()
        activity.startAnimating()

        //Rendering and saving
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
          
          let editor = VideoEditor()
          
          editor.applyQuestionOverlayToVideoWithURL(FileManager.default.getDocumentsDirectory().appendingPathComponent("video.mov"),
                                                    questions: self.questionQueue,
                                                    secondsWaypoints: self.answerTimeWaypoints,
                                                    completion: { (status, url) in
                                                      DispatchQueue.main.async {
                                                        activityContainer.removeFromSuperview()
                                                      }
                                                      switch status {
                                                      case .successful:
                                                        //Save to Library
                                                        PHPhotoLibrary.shared().saveVideoToCameraRoll(videoURL: url!, completion: { (status) in

                                                          switch status {

                                                          case .successful:
                                                            self.present({

                                                              let alert = UIAlertController(title: "Success!", message: "The video has been saved to Camera Roll", preferredStyle: .alert)
                                                              alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                              return alert

                                                            }(), animated: true, completion: {
                                                              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                                self.navigationController?.popToRootViewController(animated: true)
                                                              })
                                                            })

                                                          case .failed(let message):
                                                            self.present({

                                                              let alert = UIAlertController(title: "Fail!", message: message, preferredStyle: .alert)
                                                              alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                              return alert

                                                            }(), animated: true, completion: {
                                                              DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                                self.navigationController?.popToRootViewController(animated: true)
                                                              })
                                                            })

                                                          }

                                                        })
                                                      case .failed(let message):
                                                        self.present({

                                                          let alert = UIAlertController(title: "Fail!", message: message, preferredStyle: .alert)
                                                          alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
                                                          return alert

                                                        }(), animated: true, completion: {
                                                          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                                            self.navigationController?.popToRootViewController(animated: true)
                                                          })
                                                        })

                                                      }
                                                      
          })
        })

      default:
        break
      }
    }
  }

  func setQuestionWithIndex(_ index: Int) {
    questionLabel.text = questionQueue[index]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    previewView = UIView()
    previewView.frame = view.frame
    previewView.tag = 101

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
    
    nextButton = CustomButton(frame: CGRect.init(x: view.bounds.width - 120, y: view.bounds.height - 60, width: 100, height: 40))
    nextButton.setTitle("Next", for: .normal)
    nextButton.cornerRadius = 20
    nextButton.borderWidth = 2
    nextButton.borderColor = UIColor.white
    nextButton.addTarget(self, action: #selector(nextButtonTap), for: .touchUpInside)
    nextButton.layer.opacity = 0
    view.addSubview(nextButton)
    
    questionOverlayView = UIView()
    questionOverlayView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.3)
    questionOverlayView.backgroundColor = UIColor.black
    questionOverlayView.alpha = 0.5
    
    questionLabel = UILabel()
    questionLabel.frame = CGRect(x: 20, y: 20, width: questionOverlayView.bounds.width - 40, height: questionOverlayView.bounds.height - 40)
    questionLabel.textColor = UIColor.white
    questionOverlayView.addSubview(questionLabel)
    questionLabel.font = UIFont.boldSystemFont(ofSize: 26)
    questionLabel.text = ""
    questionLabel.numberOfLines = 0

    questionOverlayView.layer.opacity = 0
    
    view.insertSubview(questionOverlayView, belowSubview: actionButton)
    
  }
  
  func actionButtonTap(){
    
    switch status {
    case .idle:
      status = .begin
    case .recording:
      answerTimeWaypoints.append(timeElapsedSeconds)
      status = .finished
    default:
      break
    }
    
  }
  
  func nextButtonTap(){
    
    currentQuestionIndex += 1
    
    setQuestionWithIndex(currentQuestionIndex)
    
    answerTimeWaypoints.append(timeElapsedSeconds)
    
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
                                                              position: .front).devices {
      captureDevice = availableDevices.first!
      beginSession()
    }
    
  }


  
  func beginSession() {
    
    do {

      let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(captureDeviceInput)

      let audiodevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
      let audioinput = try AVCaptureDeviceInput(device: audiodevice)
      captureSession.addInput(audioinput)

    } catch {

      print(error.localizedDescription)

    }
    
    if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
      
      self.previewLayer = previewLayer

      previewView.layer.addSublayer(self.previewLayer)

      self.previewLayer.frame = previewView.layer.frame

      captureSession.startRunning()

      movieOutput = AVCaptureMovieFileOutput()

      if captureSession.canAddOutput(movieOutput) {
        captureSession.addOutput(movieOutput)
      }
      
      captureSession.commitConfiguration()

    }
    
  }
  
  func timerFired(_ timer: Timer) {
    timeElapsedSeconds += 1
  }
  
  func capture(_ captureOutput: AVCaptureFileOutput!,
               didStartRecordingToOutputFileAt fileURL: URL!,
               fromConnections connections: [Any]!) {
    print("didStartRecordingToOutputFileAt")
    
    timer = Timer.scheduledTimer(timeInterval: 1,
                                 target: self,
                                 selector: #selector(timerFired(_:)),
                                 userInfo: nil,
                                 repeats: true)
    
  }
  
  
  func capture(_ captureOutput: AVCaptureFileOutput!,
               didFinishRecordingToOutputFileAt outputFileURL: URL!,
               fromConnections connections: [Any]!, error: Error!) {

    print("didFinishRecordingToOutputFileAt")
    
    timer.invalidate()
    timer = nil
    
  }
  
  func getDocumentsDirectory() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
  }
  
  deinit {
    print("\(self) deallocated")
  }
  
}

