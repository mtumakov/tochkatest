//
//  DetailViewController.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 29/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    let item: Item?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.item = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.item = nil
        super.init(coder: aDecoder)
    }
    
    init(item: Item) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Return", style: .plain, target: self, action: #selector(returnButtonTapped(_:)))
    }
    
    func setupUI() {
        let scrollView = UIScrollView()
        let imageView = UIView()
        let titleView = UILabel()
        let contentView = UILabel()
        
        view.addSubview(scrollView)
        [imageView, titleView, contentView].forEach { scrollView.addSubview($0) }
        
        let image = UIImageView()
        imageView.addSubview(image)
        image.downloaded(from: (item?.urlToImage!)!)
        
        image.fillSuperview()
        image.alignmentRect(forFrame: imageView.frame)
        
        
        scrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor,
                          padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        
        imageView.anchor(top: scrollView.safeAreaLayoutGuide.topAnchor, leading: nil,
                        bottom: nil, trailing: scrollView.safeAreaLayoutGuide.trailingAnchor,
                        padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 150, height: 80))
        
        titleView.anchor(top: imageView.topAnchor, leading: scrollView.safeAreaLayoutGuide.leadingAnchor,
                         bottom: nil, trailing: imageView.leadingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 16))

        contentView.anchor(top: imageView.bottomAnchor, leading: scrollView.safeAreaLayoutGuide.leadingAnchor,
                          bottom: scrollView.bottomAnchor, trailing: scrollView.trailingAnchor,
                          padding: .init(top: 48, left: 0, bottom: 0, right: 0))
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        titleView.textAlignment = .natural
        titleView.text = item?.title
        titleView.numberOfLines = 0
        
        contentView.textAlignment = .natural
        contentView.text = item?.description
        contentView.numberOfLines = 0
    }
    
    @objc func returnButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension UIView {
    func fillSuperview() {
        anchor(top: superview?.topAnchor, leading: superview?.leadingAnchor, bottom: superview?.bottomAnchor, trailing: superview?.trailingAnchor)
    }
    
    func anchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero)  {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right ).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String?, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let link = link else {
            return
        }
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
