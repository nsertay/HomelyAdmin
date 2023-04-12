//
//  NewApartmentTableViewController.swift
//  HomelyAdmin
//
//  Created by Nurmukhanbet Sertay on 10.04.2023.
//

import UIKit
import Firebase
import FirebaseStorage

class NewApartmentTableViewController: UITableViewController {
    
    var allFieldsFilled = true
    
    let db = Firestore.firestore()
  
    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    
    @IBOutlet var cityTextField: RoundedTextField! {
        didSet {
            cityTextField.tag = 2
            cityTextField.delegate = self
        }
    }
    
    @IBOutlet var addressTextField: RoundedTextField! {
        didSet {
            addressTextField.tag = 3
            addressTextField.delegate = self
        }
    }
    
    @IBOutlet var priceTextField: RoundedTextField! {
        didSet {
            priceTextField.tag = 4
            priceTextField.delegate = self
        }
    }
    
    @IBOutlet var commisDateTextView: UITextView! {
        didSet {
            commisDateTextView.tag = 5
            commisDateTextView.layer.cornerRadius = 10.0
            commisDateTextView.layer.masksToBounds = true
            
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let photoSourceController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true)
                }
            })
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .photoLibrary
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true)
                }
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            
            
            
            photoSourceController.addAction(cameraAction)
            photoSourceController.addAction(photoLibraryAction)
            photoSourceController.addAction(cancelAction)
            
            
            present(photoSourceController, animated: true)
        }
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let apartment = Apartment(
            name: nameTextField.text!,
            price: priceTextField.text!,
            address: addressTextField.text!,
            city: cityTextField.text!,
            commisDate: commisDateTextView.text
        )
        
       
        
        let alertController = UIAlertController(title: "", message: "Are you sure about adding?", preferredStyle: .alert)

        let addAlertAction = UIAlertAction(title: "Yes", style: .default) {_ in
           
            self.upload(photo: self.photoImageView.image!) { result in
                switch result {
                case .success(let url):
                    self.addApartment(apartment: apartment, photoUrl: url)
                    self.alertCreater(message: "Success", text: "Uploaded \(url)")
                case .failure(let error):
                    self.alertCreater(message: "Failure", text: error.localizedDescription)
                }
            }
        }

        let cancel = UIAlertAction(title: "No", style: .destructive)

        alertController.addAction(addAlertAction)
        alertController.addAction(cancel)

        present(alertController, animated: true)
        
        
        
        
    }
            
    
//

    func alertCreater(message: String, text: String) {
        
        let alertcontroller = UIAlertController(title: message , message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .destructive)
        
        alertcontroller.addAction(alertAction)
        present(alertcontroller, animated: true)
    }
    
    func addApartment(apartment: Apartment, photoUrl: URL) {

        let apartmentsCollectionRef = db.collection("apartments")

        var apartmentData = apartment.toDictionary()
        apartmentData["image"] = photoUrl.absoluteString // add the photo URL to the data

        apartmentsCollectionRef.addDocument(data: apartmentData)

//        do {
//            let _ = try apartmentsCollectionRef.addDocument(data: apartmentData)
//        } catch let error {
//            print("Error adding apartment: \(error.localizedDescription)")
//        }
    }
    
    
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {

        print("saving")

        let apartmentsCollectionRef = db.collection("apartments")

        let documentId = apartmentsCollectionRef.document().documentID

        let ref = Storage.storage().reference().child("images").child("\(documentId)")

        guard let imageData = photoImageView.image?.pngData() else {
            return
        }

        ref.putData(imageData) { error in
            ref.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }

                completion(.success(url))
            }

        }
    }
}

//if nameTextField.text == "" || typeTextField.text == "" || addressTextField.text == "" || phoneTextField.text == "" || descriptionTextView.text == "" {
//    let alertController = UIAlertController(title: "Oops", message: "We can't proceed because one of the fields is blank. Please note that all fields are required.", preferredStyle: .alert)
//    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//    alertController.addAction(alertAction)
//    present(alertController, animated: true, completion: nil)
//
//    return


extension NewApartmentTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextField.becomeFirstResponder()
        }
        return true
    }
}

extension NewApartmentTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
        }
        
        dismiss(animated: true)
    }
}
