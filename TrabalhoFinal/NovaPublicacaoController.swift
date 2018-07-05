//
//  NovaPublicacaoController.swift
//  TrabalhoFinal
//
//  Created by Maicon on 01/07/18.
//  Copyright © 2018 Maicon. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire

class NovaPublicacaoController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var descricao: UITextView!
    var codigoPub: Int = 0
    var owner: ViewController = ViewController()
    var coordenadas: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var unique: String = UIDevice.current.identifierForVendor!.uuidString
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(addTapped))
        print("x: " + String(coordenadas.latitude) + " - y: " + String(coordenadas.longitude))
    }
    
    @IBAction func takePic(_ sender: Any) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func addTapped(_ sender: Any) {
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let image = self.imagem.image {
                    let imageData = UIImageJPEGRepresentation(image, 0.8)
                    multipartFormData.append(imageData!, withName: "image", fileName: "photo.jpg", mimeType: "jpg/png")
                }
                
                multipartFormData.append(self.descricao.text.data(using: .utf8)!, withName: "descricao")
            multipartFormData.append(String(self.coordenadas.latitude).data(using: .utf8)!, withName: "lat")
            multipartFormData.append(String(self.coordenadas.longitude).data(using: .utf8)!, withName: "long")
                
                multipartFormData.append(self.unique.data(using: .utf8)!, withName: "unique")
        },
            to: "https://projetoserver.herokuapp.com/publicacao/" + (self.codigoPub > 0 ? String(self.codigoPub) + "/" : ""),
            method: self.codigoPub > 0 ? HTTPMethod.put : HTTPMethod.post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        debugPrint(response)
                        
                    }
                case .failure(let encodingError):
                    print("encoding Error : \(encodingError)")
                }
        })
        
        self.navigationController?.popViewController(animated: true)
        
        owner.marker.map = nil        
        owner.addingMarker = false
        owner.addButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        imagem.image = info["UIImagePickerControllerOriginalImage"] as? UIImage
    }
}

