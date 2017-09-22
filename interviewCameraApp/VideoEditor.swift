//
//  VideoEditor.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 20.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoEditor {
  
  func overlayWith(_ text: String, size: CGSize) -> CALayer {
    
    let containerLayer = CALayer()
    let textLayer = CATextLayer()
    
    containerLayer.frame = CGRect(x: 0, y: 0,
                                  width: size.width,
                                  height: size.height * 0.3)
    
    textLayer.frame = CGRect(x: 20, y: 20, width: containerLayer.bounds.width - 40, height: containerLayer.bounds.height - 40)
//    containerLayer.opacity = 0.5
    containerLayer.backgroundColor = UIColor.black.cgColor
    
    textLayer.string = text
    textLayer.foregroundColor = UIColor.white.cgColor
    textLayer.isWrapped = true
    textLayer.truncationMode = kCATruncationNone
    
    containerLayer.addSublayer(textLayer)
    
    return containerLayer
    
  }
  
  func applyVideoEffectTo(_ composition: AVMutableVideoComposition,
                          overlays: [CALayer],
                          size: CGSize) {
    
    //    let overlay = overlayWith(_text: "TEEEEST", size: size)
    let parentLayer = CALayer()
    let videoLayer = CALayer()
    
    parentLayer.frame = CGRect(origin: .zero, size: size)
    videoLayer.frame = CGRect(origin: .zero, size: size)
    
    parentLayer.addSublayer(videoLayer)
    for item in overlays {
      item.opacity = 0
      parentLayer.addSublayer(item)
    }
    
    composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
    
  }
  
  private func getFramesAnimation(beginTime: TimeInterval,
                                  duration: TimeInterval) -> CABasicAnimation {
    
    let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
    //MARK: Play with animation to achieve smooth transitions
    animation.beginTime = beginTime
    animation.duration = duration
    animation.fromValue = 0.5
    animation.toValue = 0
    animation.isAdditive = true
    animation.fillMode = kCAFillModeRemoved
//    animation.fillMode = kCAFillModeBoth
    animation.isRemovedOnCompletion = false
    
    return animation
  }
  
  private func addAudioTrack(composition: AVMutableComposition, videoAsset: AVURLAsset) {
    let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
    let audioTracks = videoAsset.tracks(withMediaType: AVMediaTypeAudio)
    for audioTrack in audioTracks {
      try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: kCMTimeZero)
    }
  }
  
  func applyQuestionOverlayToVideoWithURL(_ videoURL: URL,
                                          questions: [String],
                                          secondsWaypoints: [Int],
                                          completion: @escaping ((ProcessCompletionStatus, URL?)->())){
    
    typealias QuestionAnswerTimePair = (String, Int)
    
    var questionAnswerPairs = [QuestionAnswerTimePair]()
    
    for question in questions {
      for time in secondsWaypoints {
        questionAnswerPairs.append((question, time))
      }
    }

    let videoAsset = AVAsset(url: videoURL)
    
    let mixComposition = AVMutableComposition()
    
    let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
    let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try! audioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                    of: videoAsset.tracks(withMediaType: AVMediaTypeAudio).first!,
                                    at: kCMTimeZero)
    
    try! videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration),
                                    of: videoAsset.tracks(withMediaType: AVMediaTypeVideo).first!,
                                    at: kCMTimeZero)
    
    let mainInstruction = AVMutableVideoCompositionInstruction()
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
    
    let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
    let videoAssetTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first!
    
    var videoAssetOrientation = UIImageOrientation.up
    
    var isVideoAssetPortrait = false
    
    let videoTransform = videoAssetTrack.preferredTransform
    
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
          videoAssetOrientation = UIImageOrientation.right
          isVideoAssetPortrait = true
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
          videoAssetOrientation =  UIImageOrientation.left
          isVideoAssetPortrait = true;
        }
        if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
          videoAssetOrientation =  UIImageOrientation.up
        }
        if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
          videoAssetOrientation = UIImageOrientation.down
        }
    
    videoLayerInstruction.setTransform(videoAssetTrack.preferredTransform, at: kCMTimeZero)
    videoLayerInstruction.setOpacity(0, at: videoAsset.duration)
    
    mainInstruction.layerInstructions = [videoLayerInstruction]
    let mainCompositionInst = AVMutableVideoComposition(propertiesOf: videoAsset)
    
    var naturalSize: CGSize
    if isVideoAssetPortrait {
      naturalSize = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
    } else {
      naturalSize = videoAssetTrack.naturalSize
    }
    
    
    mainCompositionInst.renderSize = naturalSize
    mainCompositionInst.instructions = [mainInstruction]
    mainCompositionInst.frameDuration = CMTimeMake(1, 30)
    
    
    var overlays = [CALayer]()
    
//    for (index, item) in questions.enumerated() {
//
//      let overlay = overlayWith(item, size: naturalSize)
//
//      if item == questions.first!{
//        let animation: CABasicAnimation = getFramesAnimation(beginTime: AVCoreAnimationBeginTimeAtZero, duration: 1)
//        overlay.add(animation, forKey: "fadeOut")
//      } else {
//        let animation: CABasicAnimation = getFramesAnimation(beginTime: TimeInterval(secondsWaypoints[index - 1]) + 0.5, duration: 1)
//        overlay.add(animation, forKey: "fadeOut")
//      }
//      overlay.displayIfNeeded()

//      overlays.append(overlay)
//    }
    let overlay = overlayWith(questions.first!, size: naturalSize)
    
    overlay.add(getFramesAnimation(beginTime: AVCoreAnimationBeginTimeAtZero, duration: 2), forKey: "fadeout")
//    applyVideoEffectTo(mainCompositionInst, overlays: overlays, size: naturalSize)
    applyVideoEffectTo(mainCompositionInst, overlays: [overlay], size: naturalSize)
    
    let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
    exportSession.videoComposition = mainCompositionInst
    exportSession.outputFileType = AVFileTypeQuickTimeMovie
    exportSession.outputURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("final.mov")
    FileManager.default.checkFileAndDeleteAtURL(FileManager.default.getDocumentsDirectory().appendingPathComponent("final.mov"),
                                                completion: {
                                                  exportSession.exportAsynchronously(completionHandler: {
                                                    switch exportSession.status{
                                                      
                                                    case .completed:
                                                      completion(.successful,FileManager.default.getDocumentsDirectory().appendingPathComponent("final.mov"))
                                                    case .failed:
                                                      completion(.failed(error: "Failed to export"), nil)
                                                    default:
                                                      break
                                                    }
                                                  })
    })
    
  }
  
}
