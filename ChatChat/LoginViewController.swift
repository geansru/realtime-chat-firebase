import UIKit
import Firebase

class LoginViewController: UIViewController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: @IBAction's
    @IBAction func loginDidTouch(sender: AnyObject) {
        FirebaseHelper.shared.rootRef.authAnonymouslyWithCompletionBlock { (error: NSError!, auth: FAuthData!) -> Void in
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
        dst.senderId = FirebaseHelper.shared.rootRef.authData.uid
        dst.senderDisplayName = "Anonymous"
    }
}

