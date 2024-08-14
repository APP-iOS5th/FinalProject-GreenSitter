//
//  ProfileImageViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func changeImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadImage(image: editedImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updateNickname(imageURL)
                    self.imageButton.setImage(editedImage, for: .normal)
                }
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadImage(image: originalImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updateNickname(imageURL)
                    self.imageButton.setImage(originalImage, for: .normal)
                }
            }
        }
    }
}
