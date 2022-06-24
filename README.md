# SubsCraft

## Common

* Give repository read permissions to your github account
* Add dependency https://github.com/appstea/SubsCraft.git to your target via SPM
* Add github token to xcode account to let xcode fetch package from private repo via SPM

## Project

* Add GoogleService-Info.plist to your project
* Add next fields to Info.plst:
- FirebaseAppDelegateProxyEnabled = NO
- branch_key = <Your branch api key> # e.g. key_live_pj3V9nLR39qPjoKPG34IFcjnCDmV0OCI

## Code

* Example of integration via config:
```
import SubsCraftCore

enum Subs {

  static let core = SubsCraftCore.Instance(
    config: .init(
      subs: .init(
        apiKey: "appl_PrQxhLfrujRwauAlGngBUArKhIK",
        offering: "com.appstea.proto.first",
        isDebug: isDebug,
        urls: .init(
          policy: "https://appstea.com/legal/privacy-policy/",
          terms: "https://appstea.com/legal/terms-of-use/"
        )
      ),
      analytics: .init(
        isOSLogEnabled: isDebug || isAdHoc,
        isFirebaseEnabled: true,
        isBranchEnabled: true
      ),
      ui: .init(
        permissions: .custom(),
        subscription: .custom(),
        banner: .custom()
      )
    )
  )

}

// MARK: - Banner.Custom

fileprivate extension Config.UI.Banner {

  static func custom() -> Self? {
    var `default` = Config.UI.Banner.Default()
    `default`.title = "TexT"
    return Self(default: `default`)
    // return nil
  }

}

// MARK: - Permissions.Custom

fileprivate extension Config.UI.Permissions {

  static func custom() -> Self? {
    var result = Self()
    result.dotColor = .red
    return result
    // return nil
  }

}

// MARK: - Subscription.Custom

fileprivate extension Config.UI.Subscription {

  static func custom() -> Self? {
    var result = Self()
    result.textColor = .red
    return result
    // return nil
  }

}

```
* In case you're using only AppDelegate setup:

AppDelegate.swift
```
import UIKit
import Cascade

@main
final class AppDelegate: Cascade.AppDelegate {

  @objc
  override func targets() -> [UIApplicationDelegate] {[ Subs.core ]}

  // ...

}
```

* In case you're using UIWindowScene setup:

AppDelegate.swift
```
import UIKit
import Cascade

@main
final class AppDelegate: Cascade.AppDelegate {

  @objc
  override func targets() -> [UIApplicationDelegate] {[ Subs.core ]}

  override func application(_ application: UIApplication,
                            configurationForConnecting connectingSceneSession: UISceneSession,
                            options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  // ...

}

```

SceneDelegate.swift
```
import UIKit
import Cascade

final class SceneDelegate: Cascade.SceneDelegate & UIWindowSceneDelegate {

  @objc
  override func targets() -> [UISceneDelegate] {[ Subs.core.scene ]}

  var window: UIWindow?

  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)
    // your setup ...
  }

}
```

* Banner integration:
```
import SubsCraftCore

class ViewController: UIViewController {

  private lazy var bannerView = Subs.core.banner(source: .bottomUpsell, intent: .normal, presenter: self)

  // MARK: - Lifecycle

  override func loadView() {
    super.loadView()
    view.addSubviews(bannerView)
  }

  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { _ in
      self.view.setNeedsLayout()
      self.view.layoutIfNeeded()
    }, completion: nil)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // layout banner view
    // e.g. via PinLayout
    let safeArea = view.pin.safeArea
    if !Subs.core.isPremium {
      bannerView.pin.start().end()
        .bottom(safeArea.bottom)
        .sizeToFit(.width)
    }
  }

}
```

To make subscription screens work as intended (to be shown from banner etc) you need to assign keyWindow to SDK somewhere in code:
```
import SubsCraftCore

Subs.core.keyWindow = window
```

* To show Permissions screen:
```
import SubsCraftCore

await Subs.core.showPermissions(from: window)
```

* To show Subscription screen:
```
import SubsCraftCore

await Subs.core.showSubs(from: window)
```

* To perform ATT check:
```
import SubsCraftCore

await Subs.core.checkATT()
```
