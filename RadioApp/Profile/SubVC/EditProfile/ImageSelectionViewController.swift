//
//  ImageSelectionViewController.swift
//  RadioApp
//
//  Created by Иван Семенов on 31.07.2024.
//

import UIKit
import SnapKit

protocol ImageSelectionDelegate: AnyObject {
    func didUpdateProfileImage(_ image: UIImage)
}

final class ImageSelectionViewController: UIViewController {
    
    private var profileImageNames = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    private let scrollView = UIScrollView()
    private var imagePicker = UIImagePickerController()
    private var profileImageSelectedIndex = 0
    var delegate: ImageSelectionDelegate?
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.5
        return blurView
    }()
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBlurBackground()
        setupScrollView()
        setupImages()
        setupConstraints()
        setupImagePicker()
    }
    
    //MARK: - Private methods
    private func setupView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: 2520, height: 200)
        view.addSubview(scrollView)
    }
    
    private func setupBlurBackground() {
        view.addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupImages() {
        var xOffset: CGFloat = 20
        for (_, imageName) in profileImageNames.enumerated() {
            if let image = UIImage(named: imageName) {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: xOffset, y: 20, width: 300, height: 300)
                imageView.layer.cornerRadius = 20
                imageView.isUserInteractionEnabled = true
                scrollView.addSubview(imageView)
                
                if imageName == "ProfilePictureEdit" {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageAddTapped(_:)))
                    imageView.addGestureRecognizer(tapGesture)
                } else {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageOtherTapped(_:)))
                    imageView.addGestureRecognizer(tapGesture)
                }
                
                xOffset += 340
            }
        }
    }
    
    @objc func imageOtherTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let _ = scrollView.subviews.firstIndex(of: tappedImageView) else {
            return
        }
        if let tappedImage = tappedImageView.image {
            delegate?.didUpdateProfileImage(tappedImage)
        }
    }

    private func setupImagePicker() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.height.equalTo(400)
            make.width.equalTo(1200)
            make.centerY.equalTo(view.snp.centerY)
        }
    }
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.view)
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           scrollView.frame.contains(tapLocation) {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageAddTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let tappedIndex = scrollView.subviews.firstIndex(of: tappedImageView) else {
            return
        }
        profileImageSelectedIndex = tappedIndex
        present(imagePicker, animated: true, completion: nil)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImageSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImageNames[profileImageSelectedIndex] = "ProfilePictureSelected"
            if let imageView = scrollView.subviews[profileImageSelectedIndex] as? UIImageView {
                imageView.image = selectedImage
                delegate?.didUpdateProfileImage(selectedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
