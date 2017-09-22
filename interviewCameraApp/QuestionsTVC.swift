//
//  QuestionsTVC.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 19.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//
import Foundation
import UIKit
import Photos
import MobileCoreServices

class QuestionsTVC: UITableViewController, UINavigationControllerDelegate {
  
  var questions = ["What is your favorite color?",
                   "What icecream do you like?",
                   "Where are you from?"]
  
//  var editButton: UIBarButtonItem!
  var addButton: UIBarButtonItem!
  var nextButton: UIBarButtonItem!
  var libButton: UIBarButtonItem!
  
  var isInEditingMode = false {
    
    didSet {
      
      if isInEditingMode == true {
        
        tableView.setEditing(false, animated: true)
//        editButton.title = "Edit"
      } else {
        
        tableView.setEditing(true, animated: true)
//        editButton.title = "Done"
        
      }
      
    }
    
  }
  
  var addQuestionPrompt: UIAlertController {
    
    let alert = UIAlertController(title: "Add a question", message: "Enter a question below.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction.init(title: "Done", style: .default, handler: { (_) in
      
      let question = alert.textFields!.first!.text!
      
      if question != "" {
        
        self.questions.append(question)
        self.tableView.reloadData()
        
      }
      
    }))
    
    alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
    
    alert.addTextField(configurationHandler: nil)
    
    return alert
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    PHPhotoLibrary.requestAuthorization { (status) in

      switch status{
      case .authorized:
        break
      case .denied:
        self.present({

          let alert = UIAlertController(title: "Access denied", message: "This app has to have access to Photo Library", preferredStyle: .alert)
          alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
          return alert

        }(), animated: true, completion: nil)

      case .restricted:

        self.present({

          let alert = UIAlertController(title: "Access restricted", message: "This app has to have access to Photo Library", preferredStyle: .alert)
          alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
          return alert

        }(), animated: true, completion: nil)

      default:
        break
      }

    }
    libButton = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(libButtonTap))
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//    editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTap))
//    navigationItem.leftBarButtonItems = [editButton, libButton]
    navigationItem.leftBarButtonItems = [libButton]
    
    addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))


    nextButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(nextTap))

    navigationItem.rightBarButtonItems = [addButton, nextButton]
  }

  var imagePickerController = UIImagePickerController()
  
  func libButtonTap(){
    
    imagePickerController.sourceType = .savedPhotosAlbum
    imagePickerController.delegate = self
    imagePickerController.mediaTypes = [kUTTypeMovie as String]
    present(imagePickerController, animated: true, completion: nil)
    
  }
  
  func nextTap(){
    guard questions.count != 0 else {
      self.present({

        let alert = UIAlertController(title: "No questions!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        return alert

      }(), animated: true, completion: nil)
      return
    }
    let videoRecorder = VideoRecorderVC()
    videoRecorder.questionQueue = questions
    navigationController?.pushViewController(videoRecorder, animated: true)

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(false, animated: true)
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

  }
  
  
  func addTap() {
    
    present(addQuestionPrompt, animated: true, completion: nil)
    
  }
  
  func editTap(){
    
    isInEditingMode = !isInEditingMode
    
  }
  
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return questions.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
    cell.textLabel?.text = questions[indexPath.row]
    cell.selectionStyle = .none
    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      questions.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
}

class PickerDelegate : NSObject, UIImagePickerControllerDelegate{
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
  }
}
extension QuestionsTVC: UIImagePickerControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    let videoURL = info[UIImagePickerControllerMediaURL] as! URL
    picker.dismiss(animated: true, completion: nil)
    let edit = VideoEditor()
    edit.applyQuestionOverlayToVideoWithURL(videoURL,
                                            questions: ["Test1", "Test2","Test3","Test4"],
                                            secondsWaypoints: [5, 10, 20, 30]) { (status, url) in
                                              
                                              switch status {
                                              case .successful:
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
                                              
                                              
    }
  }
}
