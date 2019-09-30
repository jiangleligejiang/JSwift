//
//  ImagePickerController.swift
//  RxSwiftDemo
//
//  Created by jams on 2019/9/29.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ImagePickerController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Camera", for: .normal)
        return button
    }()
    var galleryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gallery", for: .normal)
        return button
    }()
    var cropButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Crop", for: .normal)
        return button
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ImagePicker"
        
        self.view.addSubview(imageView)
        self.view.addSubview(cameraButton)
        self.view.addSubview(galleryButton)
        self.view.addSubview(cropButton)
        
        let imageW = view.bounds.size.width - 40;
        let imageH = imageW * 3.0 / 4;
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(80)
            make.centerX.equalTo(view)
            make.size.equalTo(CGSize(width: imageW, height: imageH))
        }
        
        cameraButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        
        galleryButton.snp.makeConstraints { make in
            make.top.equalTo(cameraButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        
        cropButton.snp.makeConstraints { make in
            make.top.equalTo(galleryButton.snp.bottom).offset(20)
            make.centerX.equalTo(view)
        }
        
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
//        cameraButton.addTarget(self, action: #selector(pickerButtonDidClick(button:)), for: .touchUpInside)
//        galleryButton.addTarget(self, action: #selector(pickerButtonDidClick(button:)), for: .touchUpInside)
//        cropButton.addTarget(self, action: #selector(pickerButtonDidClick(button:)), for: .touchUpInside)
        
        //rxswift
        cameraButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                .flatMap { $0.rx.didFinishPickingMediaWithInfo }
                .take(1)
            }
            .map { info in
                return info[.originalImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        galleryButton.rx.tap
            .debug()
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }
                .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                return info[.originalImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        cropButton.rx.tap
            .debug()
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                }
                .flatMap {
                    $0.rx.didFinishPickingMediaWithInfo
                }
                .take(1)
            }
            .map { info in
                return info[.editedImage] as? UIImage
            }
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
    }
    
    
    @objc
    func pickerButtonDidClick(button: UIButton) {
        let picker = UIImagePickerController()
        if button == cameraButton {
            picker.sourceType = .camera
            picker.allowsEditing = false
        } else if button == galleryButton {
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
        } else if button == cropButton {
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
        }
        
        //picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

//extension ImagePickerController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        var image: UIImage!
//        if picker.allowsEditing {
//            image = info[.editedImage] as? UIImage
//        } else {
//            image = info[.originalImage] as? UIImage
//        }
//
//        self.imageView.image = image
//        self.dismiss(animated: true, completion: nil)
//
//    }
//
//}
