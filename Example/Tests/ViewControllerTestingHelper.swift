/*

Copyright (c) 2016 Tunca Bergmen <tunca@bergmen.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

*/

import Foundation
import UIKit

open class ViewControllerTestingHelper {
    class func wait() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.01))
    }

    class func emptyViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = UIView()
        return viewController
    }

    class func prepareWindowWithRootViewController(_ viewController: UIViewController) -> UIWindow {
        let window: UIWindow = UIWindow(frame: CGRect())
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        wait()
        return window
    }

    class func presentViewController(_ viewController: UIViewController) {
        let window: UIWindow = prepareWindowWithRootViewController(emptyViewController())
        window.rootViewController?.present(viewController, animated: false, completion: nil)
        wait()
    }

    class func dismissViewController(_ viewController: UIViewController) {
        viewController.dismiss(animated: false, completion: nil)
        wait()
    }

    class func presentAndDismissViewController(_ viewController: UIViewController) {
        presentViewController(viewController)
        dismissViewController(viewController)
    }

    class func pushViewController(_ viewController: UIViewController) -> UINavigationController {
        let navigationController: UINavigationController = UINavigationController(rootViewController: emptyViewController())
        _ = prepareWindowWithRootViewController(navigationController)
        navigationController.pushViewController(viewController, animated: false)
        wait()
        return navigationController
    }
}
