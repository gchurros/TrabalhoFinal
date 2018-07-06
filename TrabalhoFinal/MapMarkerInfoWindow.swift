//
//  MapMarkerInfoWindowController.swift
//  TrabalhoFinal
//
//  Created by Maicon on 04/07/18.
//  Copyright © 2018 Maicon. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

protocol StoreDelegate {
    func didPressEdit(_ sender: GMSMarker)
    func didPressDelete(_ sender: GMSMarker)
}

protocol StoreDelegateInfoWindow {
    func setDados(descricao: String, imagem: UIImage)
}

class MapMarkerInfoWindow : UIView, StoreDelegateInfoWindow  {
    var delegate:StoreDelegate!
    var publicacao: Publicacao = Publicacao()
    var marcador : GMSMarker! = GMSMarker()
    
    @IBOutlet weak var deletarButton: UIButton!
    @IBOutlet weak var editarButton: UIButton!
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var descricao: UITextView!
    
    @IBAction func editar(_ sender: Any) {
        delegate.didPressEdit(marcador)
    }
    
    @IBAction func deletar(_ sender: Any) {
        delegate.didPressDelete(marcador)
    }
    
    func setDados(descricao: String, imagem: UIImage)   {
        self.imagem.image = imagem
        self.descricao.text = descricao
    }
    
    func desabilitarBotoes()    {
        deletarButton.isHidden = true
        editarButton.isHidden = true
        var frameRect = descricao.frame
        frameRect.size.height = 69
        descricao.frame = frameRect
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
