//
//  SceneDelegate.swift
//  ComeraPay
//
//  Created by Zuhaib Imtiaz on 09/01/2024.
//

import UIKit

var userType = "user"
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        print(Date())
        
        
        
        guard let scene = (scene as? UIWindowScene) else { return }
        self.showLaunchScreen(with: scene)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.setupAppInitialController(with: scene)
        }
    }
    
    private func showLaunchScreen(with windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        let launchVC = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        window.rootViewController = launchVC
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        NotificationCenter.default.post(name: Notification.Name("Woke"), object: nil, userInfo: ["type":""])

    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        isInBackground = true

        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }

    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        let productId = components.queryItems?.first(where: { $0.name == "productId" })?.value
        let paymentMethodId = components.queryItems?.first(where: { $0.name == "paymentMethodId" })?.value

        print("Received productId:", productId ?? "nil")
        print("Received paymentMethodId:", paymentMethodId ?? "nil")

        // Route to the correct payment screen, passing productId / paymentMethodId
    }
    
    private func setupAppInitialController(with windowScene: UIWindowScene) {
        if AppUserDefaults.shared.UDValue(.isLoggedIn) as? Bool ?? false {
            // if user is logged in then directly Land the user to home Tabbar directly
            self.setupHomeRootView(with: windowScene)
        } else if AppUserDefaults.shared.UDValue(.alreadyShowWalkThroughScreen) as? Bool ?? false {
            self.setupRootView(with: windowScene, isWalkThrough: false)
        } else {
            self.setupRootView(with: windowScene, isWalkThrough: true)
        }
    }
    
    private func setupHomeRootView(with windowScene: UIWindowScene) {
        let vc = HomeTabBarController(
            userContext: UserContext.create(
                with: UserInformation()
            )
        )
        vc.isNeedToCheckAuth = true
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func setupRootView(with windowScene: UIWindowScene, isWalkThrough: Bool) {
        var vc: UIViewController = LoginVC(viewModel: RegisterViewModel())

        if isWalkThrough {
            let viewModel = WalkThroughViewModel(httpClient: MockHttpClient())
            vc = WalkThroughsVC(viewModel: viewModel)
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(false, animated: true)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
}

