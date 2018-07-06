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
    var publicacao: Publicacao = Publicacao()
    var owner: ViewController = ViewController()
    var coordenadas: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var unique: String = UIDevice.current.identifierForVendor!.uuidString
    var imagePicker: UIImagePickerController!
    var telaInfo: StoreDelegateInfoWindow!
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Salvar", style: .done, target: self, action: #selector(addTapped))
        print("x: " + String(coordenadas.latitude) + " - y: " + String(coordenadas.longitude))
        
        if (publicacao.id > 0)  {
            self.descricao.text = publicacao.descricao
            self.imagem.image = publicacao.foto
        }
    }
    
    @IBAction func takePic(_ sender: Any) {
        let alertImagem = UIAlertController(title: "Nova imagem", message: "Selecione uma opcao abaixo", preferredStyle: UIAlertControllerStyle.alert)
        alertImagem.addAction(UIAlertAction(title: "Tirar uma foto", style: UIAlertActionStyle.default, handler: { action in
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
        }))
        alertImagem.addAction(UIAlertAction(title: "Escolher da galeria", style: UIAlertActionStyle.default, handler: { action in
            self.imagePicker =  UIImagePickerController()
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        self.present(alertImagem, animated: true, completion: nil)
    }
    
    @objc func addTapped(_ sender: Any) {
        publicacao.descricao = descricao.text
        if let image = self.imagem.image {
            publicacao.foto = image
            if (telaInfo != nil)    {
                telaInfo.setDados(descricao: descricao.text, imagem: image)
            }
        } else {
            if (telaInfo != nil)    {
                telaInfo.setDados(descricao: descricao.text, imagem: UIImage())
            }
        }
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let image = self.imagem.image {
                    let imageData = UIImageJPEGRepresentation(image, 0.8)
                    if (imageData != nil)   {
                        multipartFormData.append(imageData!, withName: "image", fileName: "photo.jpg", mimeType: "jpg/png")
                    }
                }
            multipartFormData.append(self.publicacao.descricao.data(using: .utf8)!, withName: "descricao")
            multipartFormData.append(String(self.coordenadas.latitude).data(using: .utf8)!, withName: "lat")
            multipartFormData.append(String(self.coordenadas.longitude).data(using: .utf8)!, withName: "long")
            
            multipartFormData.append(self.unique.data(using: .utf8)!, withName: "unique")
        },
            to: "https://projetoserver.herokuapp.com/publicacao/" + (self.publicacao.id > 0 ? String(self.publicacao.id) + "/" : ""),
            method: self.publicacao.id > 0 ? HTTPMethod.put : HTTPMethod.post,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let pubObj = response.result.value as? NSDictionary {
                            if (!self.editMode)  {
                                let newMarker = GMSMarker()
                                
                                if let id = pubObj.value(forKey: "id") as? Int { self.publicacao.id = id }
                                
                                newMarker.userData = self.publicacao
                                newMarker.position = self.coordenadas
                                newMarker.map = self.owner.mapaView
                            }
                        }
                        
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
        imagem.contentMode = .scaleAspectFit
        imagem.image = info["UIImagePickerControllerOriginalImage"] as? UIImage
    }
}

