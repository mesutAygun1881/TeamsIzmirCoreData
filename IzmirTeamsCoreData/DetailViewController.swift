//
//  DetailViewController.swift
//  IzmirTeamsCoreData
//
//  Created by Mesut Aygün on 27.05.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController ,UINavigationControllerDelegate , UIImagePickerControllerDelegate {

    @IBOutlet var explainLabel: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var yearText: UITextField!
    @IBOutlet var nameText: UITextField!
    var chosenTeam = ""
    var chosenTeamId : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        imageView.isUserInteractionEnabled = true
        let imageRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageRecognizer)
        
        if chosenTeam != "" {
            //coreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
             let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teams")
            let idString = chosenTeamId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let explain = result.value(forKey: "explain") as? String {
                            explainLabel.text = explain
                        }
                        if let year = result.value(forKey: "year") as? String {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                            
                        }
                    }
                }
            }catch{
                print("error")
            }
            
        }else{
            nameText.text = ""
            yearText.text = ""
        }
    }
    
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)

    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTeam = NSEntityDescription.insertNewObject(forEntityName: "Teams", into: context)
        
        newTeam.setValue(nameText.text, forKey: "name")
        newTeam.setValue(explainLabel.text, forKey: "explain")
        
        if let year = Int(yearText.text!) {
            newTeam.setValue(year, forKey: "year")
        }
        newTeam.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newTeam.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
            
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData") , object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
}
