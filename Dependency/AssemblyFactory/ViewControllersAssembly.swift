//
//  ViewControllersAssembly.swift
//  PersonalDataApp
//
//  Created by Tigran VIasyan on 26.10.22.
//

import Foundation
import Swinject

class ViewControllerAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ChatViewController.self) { r in
            let vc = ChatViewController()
            let viewModel = container.resolve(ChatViewModelType.self)!
            vc.inejct(viewModel: viewModel)
            return vc
        }.inObjectScope(.container)
    }
}
