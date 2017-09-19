//
//  FileManagerExtensions.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 19.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//

import Foundation

extension FileManager {

  func checkFileAndDeleteAtURL(_ url: URL, completion: (()->())?){

    if FileManager.default.fileExists(atPath: url.path) {

      do {
        print("File exists")
        try FileManager.default.removeItem(at: url)
      } catch {
        print(error)
      }
      print("File deleted")
      completion?()

    } else {
      print("File does not exist")
      completion?()
      
    }
    
  }
  
}
