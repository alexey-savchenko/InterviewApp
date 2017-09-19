//
//  PhotoLibraryExtensions.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 19.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//

import Foundation
import Photos

extension PHPhotoLibrary {

  func saveVideoToCameraRoll(videoURL: URL, completion: ((ProcessCompletionStatus)->())?){

    PHPhotoLibrary.shared().performChanges({

      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)

    }) { (saved, error) in

      guard error == nil else {
        completion?(ProcessCompletionStatus.failed(error: "Cannot save video to Library"))
        return
      }

      if saved {

        completion?(ProcessCompletionStatus.successful)

      }

    }

  }
  
}
