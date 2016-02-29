import UIKit
import Firebase

class LoginViewController: UIViewController {
  
    // MARK: public properties
    var ref: Firebase!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url: "https://glowing-heat-1954.firebaseio.com")
        
    }

    // MARK: @IBAction's
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authAnonymouslyWithCompletionBlock { (error: NSError!, auth: FAuthData!) -> Void in
            if let error = error {
                print(error.localizedDescription)
                return
            } else {
                self.performSegueWithIdentifier("LoginToChat", sender: nil)
            }
        }
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        guard let nav = segue.destinationViewController as? UINavigationController else {  return }
        guard let dst = nav.topViewController as? ChatViewController else {  return }
        dst.senderId = ref.authData.uid
        dst.senderDisplayName = "Anonymous"
    }
}

