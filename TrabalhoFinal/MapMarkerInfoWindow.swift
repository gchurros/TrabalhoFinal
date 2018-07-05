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

class MapMarkerInfoWindow : UIView  {
    var id : Int = 0
    var marcador : GMSMarker! = GMSMarker()
    var vc: NovaPublicacaoController = NovaPublicacaoController()
    var navigationController: UINavigationController = UINavigationController()
    
    @IBOutlet weak var imagem: UIImageView!
    @IBOutlet weak var descricao: UITextView!
    
    @IBAction func editClick(_ sender: Any) {
        navigationController.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        marcador.map = nil
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    
}
