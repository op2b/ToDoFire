

import Foundation
import Firebase
import FirebaseDatabase

struct Task {
    let title : String
    var  userId: String
    let ref: DatabaseReference?
    var complited: Bool = false
    
    init(titel: String, userID: String) {
        self.title = titel
        self.userId = userID
        self.ref = nil
    }
    init(snapshot: DataSnapshot) {
        let snapShotValue = snapshot.value as! [String: AnyObject]
        title = snapShotValue["titel"] as! String
        userId = snapShotValue["userId"] as! String
        complited = snapShotValue["complited"] as! Bool
        ref = snapshot.ref
    }
    func converToDictionary() -> Any {
        return ["titel": title, "userId": userId, "complited": complited]
    }
}
