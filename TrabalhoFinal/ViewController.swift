//
//  ViewController.swift
//  TrabalhoFinal
//
//  Created by Maicon on 01/07/18.
//  Copyright © 2018 Maicon. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import Foundation

class Publicacao    {
    var descricao: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var foto: UIImage = UIImage()
    var id: Int = 0
    var unique: String = ""
}

class ViewController: UIViewController, GMSMapViewDelegate, StoreDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapaView: GMSMapView!
    @IBOutlet weak var addButton: UIButton!
    var locationManager = CLLocationManager()
    
    var infoWindowIsOpen: Bool = false
    var markerDict: [Int: GMSMarker] = [:]
    var addingMarker : Bool = false
    //var camera = GMSCameraPosition.camera(withLatitude: 37.36, longitude: -122.0, zoom: 6.0)
    
    var marker:GMSMarker! = GMSMarker()
    var tappedMarker:GMSMarker = GMSMarker()
    var infoWindow = MapMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    @IBAction func addMarker(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        addButton.isHidden = true
        infoWindowIsOpen = false
        
        marker.map = mapaView
        addingMarker = true
        marker.position = mapaView.camera.target
        
        infoWindow.removeFromSuperview()
        tappedMarker.userData = nil
    }
    
    func didPressEdit(_ sender: GMSMarker)    {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NovaPublicacaoController") as! NovaPublicacaoController
        
        viewController.editMode = true
        viewController.publicacao = sender.userData as! Publicacao
        viewController.coordenadas.latitude = sender.position.latitude
        viewController.coordenadas.longitude = sender.position.longitude
        viewController.telaInfo = infoWindow
        viewController.owner = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didPressDelete(_ sender: GMSMarker)  {
        if (infoWindowIsOpen)    {
            Alamofire.request("https://projetoserver.herokuapp.com/publicacao/" + String((tappedMarker.userData as! Publicacao).id), method: .delete, encoding: JSONEncoding.default).responseJSON { response in
                let statusCode = response.response?.statusCode
                if (statusCode == 204) || (statusCode == 404)    {
                    sender.map = nil
                    self.infoWindow.removeFromSuperview()
                    self.infoWindowIsOpen = false
                }
            }
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NovaPublicacaoController") as! NovaPublicacaoController
        
        viewController.editMode = false
        viewController.coordenadas.latitude = marker.position.latitude
        viewController.coordenadas.longitude = marker.position.longitude
        viewController.owner = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        marker.map = nil
        
        addingMarker = false
        addButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapaView.isMyLocationEnabled = true
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        Alamofire.request("https://projetoserver.herokuapp.com/publicacao/", method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard let locaisArr = response.result.value as? NSArray else { return }
            
            for var localObj in locaisArr  {
                guard let localDic = localObj as? NSDictionary else { return }
                let marcador = GMSMarker()
                
                var localLat = 0.0
                var localLong = 0.0
                
                let publicacao = Publicacao()
                if let id = localDic.value(forKey: "id") as? Int { publicacao.id = id }
                if let descricao = localDic.value(forKey: "descricao") as? String { publicacao.descricao = descricao }
                if let imageData = localDic.value(forKey: "imagem") as? Data { publicacao.foto = UIImage(data: imageData)! }
                if let latitude = localDic.value(forKey: "lat") as? Double {
                    localLat = latitude
                    publicacao.latitude = latitude
                }
                
                if let longitude = localDic.value(forKey: "long") as? Double {
                    localLong = longitude
                    publicacao.longitude = longitude
                }
                
                marcador.position = CLLocationCoordinate2D(latitude: localLat, longitude: localLong)
                marcador.userData = publicacao
                marcador.map = self.mapaView
            }
        }
        
        addButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //mapaView.camera = camera
        mapaView.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.mapaView?.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        if (marker.userData != nil) {
            Alamofire.request("https://projetoserver.herokuapp.com/publicacao/" + String((marker.userData as! Publicacao).id), method: .get, encoding: JSONEncoding.default).responseJSON { response in
                if let pubObj = response.result.value as? NSDictionary {
                    let pub = marker.userData as! Publicacao
                    
                    if let id = pubObj.value(forKey: "id") as? Int { pub.id = id }
                    if let descricao = pubObj.value(forKey: "descricao") as? String { pub.descricao = descricao }
                    if let imageData = pubObj.value(forKey: "imagem") as? Data { pub.foto = UIImage(data: imageData)! }
                    if let unique = pubObj.value(forKey: "unique") as? String { pub.unique = unique }
                    
                    self.infoWindow.removeFromSuperview()
                    self.infoWindow = MapMarkerInfoWindow.instanceFromNib() as! MapMarkerInfoWindow
                    self.infoWindow.marcador = marker
                    self.infoWindow.publicacao = pub
                    self.infoWindow.center = mapView.projection.point(for: marker.position)
                    self.infoWindow.center.y -= 120
                    self.infoWindow.delegate = self
                    self.infoWindow.isUserInteractionEnabled = true
                    self.infoWindowIsOpen = true
                    self.infoWindow.descricao.text = pub.descricao
                    self.infoWindow.imagem.image = pub.foto
                    
                    if (UIDevice.current.identifierForVendor!.uuidString != pub.unique) {
                        self.infoWindow.desabilitarBotoes()
                    }
                    
                    self.view.addSubview(self.infoWindow)
                }
            }
        }
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (addingMarker)   {
            marker.position = position.target
        }
        
        if (infoWindowIsOpen){
            infoWindow.center = mapView.projection.point(for: tappedMarker.position)
            infoWindow.center.y -= 120
        }
    }    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
        infoWindowIsOpen = false
    }
}
