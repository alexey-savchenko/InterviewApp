//
//  QuestionsTVC.swift
//  interviewCameraApp
//
//  Created by Alexey Savchenko on 19.09.17.
//  Copyright © 2017 svchdzgn. All rights reserved.
//

import UIKit

class QuestionsTVC: UITableViewController {
  
  var questions = ["What is your favorite color?",
                   "What icecream do you like?",
                   "Where are you from?"]
  
  var editButton: UIBarButtonItem!
  var addButton: UIBarButtonItem!
  var nextButton: UIBarButtonItem!
  
  
  var isInEditingMode = false {
    
    didSet {
      
      if isInEditingMode {
        
        tableView.setEditing(false, animated: true)
        editButton.title = "Edit"
      } else {
        
        tableView.setEditing(true, animated: true)
        editButton.title = "Done"
        
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
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTap))
    navigationItem.leftBarButtonItems = [editButton]
    
    addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTap))


    nextButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(nextTap))

    navigationItem.rightBarButtonItems = [addButton, nextButton]
  }

  func nextTap(){

    let videoRecorder = VideoRecorderVC()
    videoRecorder.questionQueue = questions
    navigationController?.pushViewController(videoRecorder, animated: true)

  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    
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
