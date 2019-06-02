

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class TasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: UserI!
    var ref: DatabaseReference!
    var taskArray = Array<Task>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let correntUser = Auth.auth().currentUser else {return}
        user = UserI(user: correntUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: { (snapShot) in
             var _tasks = Array<Task>()
            for i in snapShot.children {
                let task = Task(snapshot: i as! DataSnapshot)
                _tasks.append(task)
            }
            self.taskArray = _tasks
            self.tableView.reloadData()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ref.removeAllObservers()
        
    }
    
    //кол-во ячеек (обязательный метод)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    
    
    //что мы будем отоброжать внутри ячийки (обязатльный метод)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        let taskTitel = task.title
        let isComplited = task.complited
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = taskTitel
        toogleComplition(cell, isComplited: isComplited )
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //delete cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete  {
            let task = taskArray[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell =  tableView.cellForRow(at: indexPath) else {return}
        let task = taskArray[indexPath.row]
        let isComplited = !task.complited
        
        toogleComplition(cell, isComplited: isComplited)
        task.ref?.updateChildValues(["complited": isComplited])
    }
    
    
    func toogleComplition(_ cell: UITableViewCell, isComplited:Bool) {
        cell.accessoryType = isComplited ? .checkmark : .none
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        ac.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = ac.textFields?.first, textField.text != "" else { return }
            
            let task = Task(titel: textField.text!, userID: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.converToDictionary())
            
        }
      
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        ac.addAction(save)
        ac.addAction(cancel)
        
        present(ac, animated: true, completion: nil)
    }
    

    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
           try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
