//
//  GithubSignupViewModel1.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import RxSwift
import RxCocoa

class GithubSignupViewModel1 {
    
    let validateUsername: Observable<ValidationResult>
    let validatePassword: Observable<ValidationResult>
    let validatePasswordRepeated: Observable<ValidationResult>
    
    let signupEnabled: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>
    
    init(input:
        (username: Observable<String>,
        password: Observable<String>,
        repeatedPassword: Observable<String>,
        loginTaps: Observable<Void>
        ),
         dependency: (
        API: GitHubAPI,
        validationService: GitHubValidationService,
        wireFrame: Wireframe
        )
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireFrame = dependency.wireFrame
        
        validateUsername = input.username.flatMapLatest{ username in
            return validationService.validateUsername(username)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "Error contacting server"))
            }
            .share(replay: 1)
        
        validatePassword = input.password.map { password in
            return validationService.validatePassword(password)
        }
        .share(replay: 1)
        
        validatePasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
            .share(replay: 1)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()
        
        let usernameAndPassword = Observable.combineLatest(input.username, input.password) { (username: $0, password: $1) }
        
        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { pair in
                return API.signup(pair.username, password: pair.password)
                    .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(false)
                .trackActivity(signingIn)
            }
            .flatMapLatest{ loggedIn -> Observable<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to Github failed"
                return wireFrame.promptFor(message, cancelAction: "OK", actions: [])
                    .map{ _ in
                        loggedIn
                    }
            }
            .share(replay: 1)
        
        signupEnabled = Observable.combineLatest(
             validateUsername,
             validatePassword,
             validatePasswordRepeated,
             signingIn.asObservable()
            ) { username, password, repeatPassword, signingIn in
                username.isValid &&
                password.isValid &&
                repeatPassword.isValid &&
                !signingIn
            }
            .distinctUntilChanged()
            .share(replay: 1)
    }
}
