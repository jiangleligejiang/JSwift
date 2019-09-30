//
//  Protocols.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import RxSwift
import RxCocoa

enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

enum SignupState {
    case signedUp(signedUp: Bool)
}

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
