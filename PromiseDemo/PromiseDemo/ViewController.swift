//
//  ViewController.swift
//  PromiseDemo
//
//  Created by jams on 2019/10/21.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit
import PromiseKit
import CoreLocation

class ViewController: UIViewController {
    
    var imageView1: UIImageView!
    
    var imageView2: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let xOffset = (self.view.bounds.size.width - 200) / 2
        imageView1 = UIImageView(frame: CGRect(x: xOffset , y: 80, width: 200, height: 200))
        imageView1.contentMode = .scaleAspectFit
        self.view.addSubview(imageView1)
        
        imageView2 = UIImageView(frame: CGRect(x: xOffset, y: imageView1.frame.maxY + 20, width: 200, height: 200))
        imageView2.contentMode = .scaleAspectFit
        self.view.addSubview(imageView2)
        
        self.fetchImage()
        
        firstly {
            self.getIcon(name: "photo-1570397382379-a66f8b2aa37f")
        }.done { (image) in
            self.imageView1.image = image
        }.catch { (error) in
            self.show(UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert), sender: self)
        }
        
    }
    
    func fetchImages() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url1 = URL(string: "https://images.unsplash.com/photo-1570397382379-a66f8b2aa37f")!
        let fetch1 = URLSession.shared.dataTask(.promise, with: url1).compactMap{ UIImage(data: $0.data) }
        
        let url2 = URL(string: "https://images.unsplash.com/photo-1570949654138-dab4fdd8c579")!
        let fetch2 = URLSession.shared.dataTask(.promise, with: url2).compactMap{ UIImage(data: $0.data) }
        
        firstly {
            when(fulfilled: fetch1, fetch2)
        }.done { (image1, image2) in
            self.imageView1.image = image1
            self.imageView2.image = image2
        }.ensure {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { (error) in
            self.show(UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert), sender: self)
        }
        
    }
    
    func fetchImage() {
        
        firstly {
            Promise<UIImage>() { seal in
                let url = URL(string: "https://images.unsplash.com/photo-1570949654138-dab4fdd8c579")!
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        seal.reject(error)
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data){
                        seal.fulfill(image)
                        return
                    }
                    let err = NSError(domain: "image", code: -1, userInfo: [NSLocalizedDescriptionKey : "can not get data"])
                    seal.reject(err)
                }
                task.resume()
            }
        }.done { (image) in
            self.imageView1.image = image
        }.ensure {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { (error) in
            self.show(UIAlertController(title: "error", message: error.localizedDescription, preferredStyle: .alert), sender: self)
        }
        
    }
    
    func getIcon(name iconName: String) -> Promise<UIImage> {
        return Promise<UIImage> {
            getFile(named: iconName, completion: $0.resolve)
        }
        .recover { _ in
            self.getImageFromNetwork(named: iconName)
        }
    }
    
    private func getImageFromNetwork(named iconName: String) -> Promise<UIImage> {
        
        let urlString = "https://images.unsplash.com/\(iconName)"
        let url = URL(string: urlString)!
        
        return firstly {
            URLSession.shared.dataTask(.promise, with: url)
        }.then(on: DispatchQueue.global(qos: .background)) { urlResponse in
            return Promise {
                self.saveFile(named: iconName, data: urlResponse.data, completion: $0.resolve)
            }.then(on: DispatchQueue.global(qos: .background)) {
                return Promise.value(UIImage(data: urlResponse.data)!)
            }
        }
    }
    
    private func saveFile(named: String, data: Data, completion: @escaping (Error?) -> Void) {
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(named + ".png") else {
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: path)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
   
    private func getFile(named: String, completion: @escaping (UIImage?, Error?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            if let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(named + ".png"),
                let data = try? Data(contentsOf: path),
                let image = UIImage(data: data) {
                DispatchQueue.main.async { completion(image, nil) }
            } else {
                let error = NSError(domain: "ImageNotFound", code: 0, userInfo: [NSLocalizedDescriptionKey : "Image file '\(named)' not found."])
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        
    }
    
}



