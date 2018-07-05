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

class ViewController: UIViewController, GMSMapViewDelegate {
    @IBOutlet var mapaView: GMSMapView!
    @IBOutlet weak var addButton: UIButton!
    
    var markerDict: [Int: GMSMarker] = [:]
    var addingMarker : Bool = false
    var camera = GMSCameraPosition.camera(withLatitude: 37.36, longitude: -122.0, zoom: 6.0)
    
    var marker:GMSMarker! = GMSMarker()
    var tappedMarker:GMSMarker = GMSMarker()
    var infoWindow = MapMarkerInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    @IBAction func addMarker(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        addButton.isHidden = true
        
        marker.map = mapaView
        addingMarker = true
        marker.position = mapaView.camera.target
        
        infoWindow.removeFromSuperview()
        tappedMarker.userData = nil
    }
    
    @IBAction func save(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NovaPublicacaoController") as! NovaPublicacaoController
        
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
        
        Alamofire.request("https://projetoserver.herokuapp.com/publicacao/", method: .get, encoding: JSONEncoding.default).responseJSON { response in
            guard let locaisArr = response.result.value as? NSArray else { return }
            
            for var localObj in locaisArr  {
                guard let localDic = localObj as? NSDictionary else { return }
                let marcador = GMSMarker()
                
                guard let id = localDic.value(forKey: "id") as? Int else { return }
                guard let latitudeStr = localDic.value(forKey: "lat") as? Double else { return }
                guard let longitudeStr = localDic.value(forKey: "long") as? Double else { return }
                
                marcador.position = CLLocationCoordinate2D(latitude: latitudeStr, longitude: longitudeStr)
                marcador.userData = id
                marcador.map = self.mapaView
            }
        }
        
        addButton.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        mapaView.camera = camera
        mapaView.delegate = self
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = MapMarkerInfoWindow.instanceFromNib() as! MapMarkerInfoWindow
        infoWindow.marcador = marker
        infoWindow.id = marker.userData as! Int
        infoWindow.center = mapView.projection.point(for: marker.position)
        infoWindow.center.y -= 150
        
        let viewController = storyboard?.instantiateViewController(withIdentifier: "NovaPublicacaoController") as! NovaPublicacaoController
        
        if (tappedMarker.userData != nil)   {
            viewController.codigoPub = tappedMarker.userData as! Int
        }
        
        viewController.coordenadas.latitude = marker.position.latitude
        viewController.coordenadas.longitude = marker.position.longitude
        viewController.owner = self
        
        infoWindow.vc = viewController
        infoWindow.navigationController = navigationController!
        
        self.view.addSubview(infoWindow)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (addingMarker)   {
            marker.position = position.target
        }
        
        if (tappedMarker.userData != nil){
            infoWindow.center = mapView.projection.point(for: tappedMarker.position)
            infoWindow.center.y -= 150
        }
    }    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
}
