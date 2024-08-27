//
//  ProfileImageViewModel.swift
//  GreenSitter
//
//  Created by 차지용 on 8/13/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @objc func changeImageTap() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        let userId = Auth.auth().currentUser?.uid ?? ""
        
        if let editedImage = info[.editedImage] as? UIImage {
            uploadImage(image: editedImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updatePostsImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(editedImage, for: .normal)
                }
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadImage(image: originalImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updatePostsImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(originalImage, for: .normal)
                }
            }
        }
    }

    
    func updatePostsImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("posts").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in posts collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["profileImageURL": imageURL]) { error in
                    if let error = error {
                        print("Error updating profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }

}
