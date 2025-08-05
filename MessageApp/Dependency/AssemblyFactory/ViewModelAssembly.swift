//
//  ViewModelAssembly.swift
//  PersonalDataApp
//
//  Created by Tigran VIasyan on 26.10.22.
//

import Foundation
import Swinject

class ViewModelAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ChatViewModelType.self) { r in
            return ChatViewModel()
        }.inObjectScope(.container)
    }
}
