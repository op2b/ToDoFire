

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase


struct UserI {
    let uid: String
    let email: String
    
    init(user:  User) {
        self.uid = user.uid
        self.email = user.email!
    }
    
}
