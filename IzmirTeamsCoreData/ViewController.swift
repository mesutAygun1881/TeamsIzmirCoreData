//
//  ViewController.swift
//  IzmirTeamsCoreData
//
//  Created by Mesut Aygün on 27.05.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedTeam = ""
    var selectedId : UUID?

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    @objc func addButtonClicked(){
        selectedTeam = ""
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
   
    
    @objc func getData() {
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teams")
        
        fetchRequest.returnsObjectsAsFaults = false
        do{
            
     let results = try  context.fetch(fetchRequest)
           
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                     
                }
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                     
                }
                self.tableView.reloadData()
            }
            
        }catch{
            print("error")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTeam = nameArray[indexPath.row]
        selectedId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenTeam = selectedTeam
            destinationVC.chosenTeamId = selectedId
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchedRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Teams")
        let idString = idArray[indexPath.row].uuidString
        fetchedRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchedRequest.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context.fetch(fetchedRequest)
            
            for result in results as! [NSManagedObject] {
                if let id = result.value(forKey: "id") as? UUID {
                    if id == idArray[indexPath.row] {
                    context.delete(result)
                    nameArray.remove(at: indexPath.row)
                    idArray.remove(at: indexPath.row)
                    self.tableView.reloadData()
                    do{
                        try context.save()
                    }catch{
                        
                    }
                    break
                }
            }
            }
            
        }catch{
            
        }
    }
    
}

