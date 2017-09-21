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
  
  func applyQuestionOverlayToVideoWithURL(_ videoURL: URL,
                                          questions: [String],
                                          secondsWaypoints: [Int],
                                          completion: @escaping ((ProcessCompletionStatus)->())){
    
//    typealias QuestionAnswerTimePair = (String, Int)
//    
//    var questionAnswerPairs = [QuestionAnswerTimePair]()
//    
//    for question in questions {
//      for time in secondsWaypoints {
//        questionAnswerPairs.append((question, time))
//      }
//    }
    
    let composition = AVMutableComposition()
    let videoAsset = AVURLAsset(url: videoURL)
    
    let videoTrack = videoAsset.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
    let videoDuration = videoTrack.asset!.duration
    let videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoDuration)
    
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
    
    try! compositionVideoTrack.insertTimeRange(videoTimeRange, of: videoTrack, at: kCMTimeZero)
    
    compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
    
    let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
    for item in videoAsset.tracks(withMediaType: AVMediaTypeAudio) {
      try! compositionAudioTrack.insertTimeRange(item.timeRange, of: item, at: kCMTimeZero)
    }
    
    let size = videoTrack.naturalSize
    
    let videoLayer = CALayer()
    videoLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
//    for (index, item) in questionAnswerPairs.enumerated() {
//    
//      
//
//      
//    }
    
    let layerComposition = AVMutableVideoComposition()
    layerComposition.frameDuration = CMTimeMakeWithSeconds(1, 30)
    layerComposition.renderSize = size
    
    layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer,
                                                                         in: getOverlayWithText(questions.first!, relativeToParentSize: size))
    
    let instruction = AVMutableVideoCompositionInstruction()
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(Float64(secondsWaypoints.first!), 60))
    
    
    
    
    let _videoTrack = composition.tracks(withMediaType: AVMediaTypeVideo).first! as AVAssetTrack
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: _videoTrack)
    instruction.layerInstructions = [layerInstruction]
    layerComposition.instructions = [instruction]
    
    let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
    exportSession.videoComposition = layerComposition
    exportSession.outputFileType = AVFileTypeQuickTimeMovie
    exportSession.outputURL = FileManager.default.getDocumentsDirectory().appendingPathComponent("final.mov")
    FileManager.default.checkFileAndDeleteAtURL(FileManager.default.getDocumentsDirectory().appendingPathComponent("final.mov"),
                                                completion: {
      exportSession.exportAsynchronously(completionHandler: { 
        switch exportSession.status{
        
        case .completed:
          completion(.successful)
        case .failed:
          completion(.failed(error: "Failed to export"))
        default:
          break
        }
      })
    })

    
    
    
    
    //    let path = NSBundle.mainBundle().pathForResource("sample_movie", ofType:"mp4")
    //    let fileURL = NSURL(fileURLWithPath: path!)
    //
    //    let composition = AVMutableComposition()
    //    var vidAsset = AVURLAsset(URL: fileURL, options: nil)
    //
    //    // get video track
    //    let vtrack =  vidAsset.tracksWithMediaType(AVMediaTypeVideo)
    //    let videoTrack:AVAssetTrack = vtrack[0] as! AVAssetTrack
    //    let vid_duration = videoTrack.timeRange.duration
    //    let vid_timerange = CMTimeRangeMake(kCMTimeZero, vidAsset.duration)
    //
    //    var error: NSError?
    //    let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: CMPersistentTrackID())
    //    compositionvideoTrack.insertTimeRange(vid_timerange, ofTrack: videoTrack, atTime: kCMTimeZero, error: &error)
    //
    //    compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
    //
    //    let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
    //    for audioTrack in audioTracks {
    //      try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, ofTrack: audioTrack, atTime: kCMTimeZero)
    //    }
    //
    //    // Watermark Effect
    //    let size = videoTrack.naturalSize
    //
    //    let imglogo = UIImage(named: "image.png")
    //    let imglayer = CALayer()
    //    imglayer.contents = imglogo?.CGImage
    //    imglayer.frame = CGRectMake(5, 5, 100, 100)
    //    imglayer.opacity = 0.6
    //
    //    // create text Layer
    //    let titleLayer = CATextLayer()
    //    titleLayer.backgroundColor = UIColor.whiteColor().CGColor
    //    titleLayer.string = "Dummy text"
    //    titleLayer.font = UIFont(name: "Helvetica", size: 28)
    //    titleLayer.shadowOpacity = 0.5
    //    titleLayer.alignmentMode = kCAAlignmentCenter
    //    titleLayer.frame = CGRectMake(0, 50, size.width, size.height / 6)
    //
    //    let videolayer = CALayer()
    //    videolayer.frame = CGRectMake(0, 0, size.width, size.height)
    //
    //    let parentlayer = CALayer()
    //    parentlayer.frame = CGRectMake(0, 0, size.width, size.height)
    //    parentlayer.addSublayer(videolayer)
    //    parentlayer.addSublayer(imglayer)
    //    parentlayer.addSublayer(titleLayer)
    //
    //    let layercomposition = AVMutableVideoComposition()
    //    layercomposition.frameDuration = CMTimeMake(1, 30)
    //    layercomposition.renderSize = size
    //    layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, inLayer: parentlayer)
    //
    //    // instruction for watermark
    //    let instruction = AVMutableVideoCompositionInstruction()
    //    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
    //    let videotrack = composition.tracksWithMediaType(AVMediaTypeVideo)[0] as! AVAssetTrack
    //    let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
    //    instruction.layerInstructions = NSArray(object: layerinstruction) as [AnyObject]
    //    layercomposition.instructions = NSArray(object: instruction) as [AnyObject]
    //
    //    //  create new file to receive data
    //    let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    //    let docsDir: AnyObject = dirPaths[0]
    //    let movieFilePath = docsDir.stringByAppendingPathComponent("result.mov")
    //    let movieDestinationUrl = NSURL(fileURLWithPath: movieFilePath)
    //
    //    // use AVAssetExportSession to export video
    //    let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHighestQuality)!
    //    assetExport.videoComposition = layercomposition
    //    assetExport.outputFileType = AVFileTypeQuickTimeMovie
    //    assetExport.outputURL = movieDestinationUrl
    //    assetExport.exportAsynchronouslyWithCompletionHandler({
    //      switch assetExport.status{
    //      case  AVAssetExportSessionStatus.Failed:
    //        println("failed \(assetExport.error)")
    //      case AVAssetExportSessionStatus.Cancelled:
    //        println("cancelled \(assetExport.error)")
    //      default:
    //        println("Movie complete")
    //
    //
    //        // play video
    //        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
    //          self.playVideo(movieDestinationUrl!)
    //        })
    //      }
    //    })
    //
  }
  
  func getOverlayWithText(_ text: String, relativeToParentSize: CGSize) -> CALayer {
    
    let parentLayer = CALayer()
    parentLayer.frame = CGRect(x: 0, y: 0,
                               width: relativeToParentSize.width,
                               height: relativeToParentSize.height * 0.3)
    
    parentLayer.backgroundColor = UIColor.black.cgColor
    parentLayer.opacity = 0.5
    
    let textLayer = CATextLayer()
    textLayer.string = text
    textLayer.frame = CGRect(x: 20, y: 20, width: parentLayer.bounds.width - 40, height: parentLayer.bounds.height - 40)
    textLayer.foregroundColor = UIColor.white.cgColor
    textLayer.font = UIFont.boldSystemFont(ofSize: 36)
    
    parentLayer.addSublayer(textLayer)
    
    return parentLayer
    
  }
  
}
