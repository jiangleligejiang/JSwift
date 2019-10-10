//
//  GitHubSignupViewController1.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/30.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class GitHubSignupViewController1 : ViewController {
    
    lazy var usernameTextField: UITextField = {
       let username = UITextField()
        username.placeholder = "Username"
        username.font = .systemFont(ofSize: 16)
        username.borderStyle = .roundedRect
        return username
    }()
    lazy var usernameValidationTextField: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .red
        return label
    }()
    lazy var passwordTextField: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.font = .systemFont(ofSize: 16)
        password.borderStyle = .roundedRect
        return password
    }()
    lazy var passwordValidationTextField: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    lazy var repeatPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password Repeat"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        return textField
    }()
    lazy var repeatPasswordValidationTextField: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    lazy var signupButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        return button
    }()
    lazy var signupLoading: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        return loading
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "GitHub"
        
        view.addSubview(usernameTextField)
        view.addSubview(usernameValidationTextField)
        view.addSubview(passwordTextField)
        view.addSubview(passwordValidationTextField)
        view.addSubview(repeatPasswordTextField)
        view.addSubview(repeatPasswordValidationTextField)
        view.addSubview(signupButton)
        signupButton.addSubview(signupLoading)
        
        self.addContraints()
        self.addViewModel()
        self.test()
    }
    
    func test() {
        let observable = Observable<Int>.create { (observer) -> Disposable in
            observer.onNext(1)
            observer.onNext(2)
            observer.onNext(3)
            observer.onCompleted()
            return Disposables.create()
        }
        
        let _ = observable.subscribe(onNext: { (num) in
            print("receive num \(num)")
        }, onError: { (error) in
            print("error:\(error.localizedDescription)")
        }, onCompleted: {
            print("recieve complete")
        }) {
            print("finished")
        }
        
    }
    
    func addContraints() {
        usernameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(80)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        
        usernameValidationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTextField.snp.bottom).offset(5)
            make.left.right.equalTo(usernameTextField)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(usernameValidationTextField.snp.bottom).offset(5)
            make.left.right.equalTo(usernameTextField)
        }
        
        passwordValidationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(usernameTextField)
        }
        
        repeatPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordValidationTextField.snp.bottom).offset(5)
            make.left.right.equalTo(usernameTextField)
        }
        
        repeatPasswordValidationTextField.snp.makeConstraints { (make) in
            make.top.equalTo(repeatPasswordTextField.snp.bottom).offset(5)
            make.left.right.equalTo(usernameTextField)
        }
        
        signupButton.snp.makeConstraints { (make) in
            make.top.equalTo(repeatPasswordValidationTextField.snp.bottom).offset(20)
            make.left.right.equalTo(usernameTextField)
            make.height.equalTo(40)
        }
        
        signupLoading.snp.makeConstraints { (make) in
            make.left.equalTo(signupButton).offset(10)
            make.centerY.equalTo(signupButton)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
    }
    
    func addViewModel() {
        let viewModel = GithubSignupViewModel1(input:
            (username: usernameTextField.rx.text.orEmpty.asObservable(),
             password: passwordTextField.rx.text.orEmpty.asObservable(),
             repeatedPassword: repeatPasswordTextField.rx.text.orEmpty.asObservable(),
             loginTaps: signupButton.rx.tap.asObservable()),
             dependency:
                (API: GitHubDefaultAPI.sharedAPI,
                 validationService: GitHubDefaultValidationService.sharedValidationService,
                 wireFrame: DefaultWireframe.shared
                )
        )
        
        viewModel.signupEnabled
            .subscribe(onNext: { [weak self] valid in
                self?.signupButton.isEnabled = valid
                self?.signupButton.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.validateUsername
            .bind(to: usernameValidationTextField.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatePassword
            .bind(to: passwordValidationTextField.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatePasswordRepeated
            .bind(to: repeatPasswordValidationTextField.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .bind(to: signupLoading.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed int \(signedIn)")
            })
            .disposed(by: disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(tapBackground)
    }
    
}
