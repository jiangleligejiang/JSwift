//
//  DefaultImplementations.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import Foundation
import RxSwift

class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    
    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)
    
    init(API: GitHubAPI) {
        self.API = API
    }
    
    let minPasswordCount = 5
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return API.usernameAvailable(username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                } else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharaters = password.count
        if numberOfCharaters == 0 {
            return .empty
        }
        if numberOfCharaters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
}

class GitHubDefaultAPI: GitHubAPI {
    let urlSession: URLSession
    
    static let sharedAPI = GitHubDefaultAPI(urlSession: URLSession.shared)
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return self.urlSession.rx.response(request: request)
            .map {  pair in
                return pair.response.statusCode == 404
            }
            .catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : true;
        return Observable.just(signupResult).delay(.seconds(1), scheduler: MainScheduler.instance)
    }
    
}

