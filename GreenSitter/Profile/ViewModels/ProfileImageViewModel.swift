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
                    self.updateUserProfileImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(editedImage, for: .normal)
                }
            }
        } else if let originalImage = info[.originalImage] as? UIImage {
            uploadImage(image: originalImage) { [weak self] imageURL in
                guard let self = self else { return }
                if let imageURL = imageURL {
                    self.updatePostsImageURL(forUserId: userId, imageURL: imageURL)
                    self.updateUserProfileImageURL(forUserId: userId, imageURL: imageURL)
                    self.imageButton.setImage(originalImage, for: .normal)
                    self.updateChatUserImageURL(forUserId: userId, imageURL: imageURL)
                    self.updateChatPostsImageURL(forUserId: userId, imageURL: imageURL)

                }
            }
        }
    }
    
    func updateUserProfileImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData(["profileImage": imageURL]) { error in
            if let error = error {
                print("Error updating profileImageURL in user document: \(error.localizedDescription)")
            } else {
                print("ProfileImageURL successfully updated in user document!")
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
                document.reference.updateData(["profileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }
    
    func updateChatUserImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("chatRooms").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat user collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["userProfileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating chat user profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL chat user successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }
    
    func updateChatPostsImageURL(forUserId userId: String, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("chatRooms").whereField("postUserId", isEqualTo: userId).getDocuments { querySnapshot, error in
            if let error = error {
                print("Firestore Query Error in chat posts collection: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                print("No matching documents found in chat posts collection")
                return
            }
            
            for document in documents {
                document.reference.updateData(["postUserProfileImage": imageURL]) { error in
                    if let error = error {
                        print("Error updating chat posts profileImageURL in document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("ProfileImageURL chat posts successfully updated in document \(document.documentID)!")
                    }
                }
            }
        }
    }

}
