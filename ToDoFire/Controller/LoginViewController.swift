

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class LoginViewController: UIViewController {
    
    let seguaeIdentifire = "tasksSegue"
    let notificationCenter = NotificationCenter.default
    var ref : DatabaseReference!
    var isKeyBoardAppear = false
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.alpha = 0
        
        ref = Database.database().reference(withPath: "users")
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

     
       
        
        //remember data user
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: self.seguaeIdentifire, sender: nil)
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
     
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
        emailTextField.text = ""
        passwordTextField.text = ""
        registerNotification()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotification()

    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        guard let keyBoardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        (self.view as! UIScrollView).contentInset.bottom = view.convert(keyBoardFrame.cgRectValue, from: nil).size.height
        
        
    }
    @objc func keyBoardWillHide(notification: Notification) {
        (self.view as! UIScrollView).contentInset.bottom = 0
    }
  
    
    @objc func tap(gesture: UITapGestureRecognizer) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    
    func displayWorningLabel(withText text: String) {
        warningLabel.text = text
        UIView.animate(withDuration: 3, animations: {[weak self] in self?.warningLabel.alpha = 1})
        
    }
    //user login
    @IBAction func LoginTappted(_ sender: Any) {
     guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != ""
        else {
            displayWorningLabel(withText: "error")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.displayWorningLabel(withText: "some error")
                return
            }
            if user != nil {
                self.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            self.displayWorningLabel(withText: "user is incorrect")
        }
        
        
    }
    @IBAction func registerTappted(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, email != "", password != ""
            else {
                displayWorningLabel(withText: "error")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            
            guard  error == nil , user != nil else {
                print(error!.localizedDescription)
                return
            }
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
            
        })
        
    
}

}

