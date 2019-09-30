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
    
    lazy var username: UITextField = {
       let username = UITextField()
        username.placeholder = "Username"
        username.font = .systemFont(ofSize: 16)
        username.borderStyle = .roundedRect
        return username
    }()
    lazy var usernameValidation: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .red
        return label
    }()
    lazy var password: UITextField = {
        let password = UITextField()
        password.placeholder = "Password"
        password.font = .systemFont(ofSize: 16)
        password.borderStyle = .roundedRect
        return password
    }()
    lazy var passwordValidation: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    lazy var repeatPassword: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password Repeat"
        textField.font = .systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        return textField
    }()
    lazy var repeatPasswordValidation: UILabel = {
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
        
        view.addSubview(username)
        view.addSubview(usernameValidation)
        view.addSubview(password)
        view.addSubview(passwordValidation)
        view.addSubview(repeatPassword)
        view.addSubview(repeatPasswordValidation)
        view.addSubview(signupButton)
        signupButton.addSubview(signupLoading)
        
        self.addContraints()
    }
    
    func addContraints() {
        username.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(80)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
        }
        
        usernameValidation.snp.makeConstraints { (make) in
            make.top.equalTo(username.snp.bottom).offset(5)
            make.left.right.equalTo(username)
        }
        
        password.snp.makeConstraints { (make) in
            make.top.equalTo(usernameValidation.snp.bottom).offset(5)
            make.left.right.equalTo(username)
        }
        
        passwordValidation.snp.makeConstraints { (make) in
            make.top.equalTo(password.snp.bottom).offset(5)
            make.left.right.equalTo(username)
        }
        
        repeatPassword.snp.makeConstraints { (make) in
            make.top.equalTo(passwordValidation.snp.bottom).offset(5)
            make.left.right.equalTo(username)
        }
        
        repeatPasswordValidation.snp.makeConstraints { (make) in
            make.top.equalTo(repeatPassword.snp.bottom).offset(5)
            make.left.right.equalTo(username)
        }
        
        signupButton.snp.makeConstraints { (make) in
            make.top.equalTo(repeatPasswordValidation.snp.bottom).offset(20)
            make.left.right.equalTo(username)
            make.height.equalTo(40)
        }
        
        signupLoading.snp.makeConstraints { (make) in
            make.left.equalTo(signupButton).offset(10)
            make.centerY.equalTo(signupButton)
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
    }
    
}
