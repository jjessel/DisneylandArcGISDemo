//
//  ViewController.swift
//  DisneyLandArcGISDemo
//
//  Created by Jeremiah Jessel on 5/30/15.
//  Copyright (c) 2015 JCubedApps. All rights reserved.
//
//  Courtyard: 33.8121 N, 117.91898 W
//  Out Front: 33.809 N, 117.919 W




import UIKit
import ArcGIS


class ViewController: UIViewController, AGSCalloutDelegate {
  
  struct MapURL {
    let worldImagery = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
    let worldStreetMap = NSURL(string: "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
    let esri2DStreetMap = NSURL(string: "http://services.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer")
  }
  
  let long = -117.91898
  let lat = 33.8121
  let envelopeDelta = 0.004
  
  var graphicsLayer: AGSGraphicsLayer!
  var graphic: AGSGraphic!
  
  @IBOutlet weak var mapView: AGSMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let mapURL = MapURL()
    
    let tiledLayer = AGSTiledMapServiceLayer(URL: mapURL.worldImagery)
    self.graphicsLayer = AGSGraphicsLayer.graphicsLayer() as! AGSGraphicsLayer
    
    self.mapView.addMapLayer(tiledLayer, withName: "Basemap Tiled Layer")
    self.mapView.addMapLayer(self.graphicsLayer, withName:"Graphics Layer")
    
    self.mapView.callout.delegate = self
    
    calloutConfiguration()
    showDefaultMapView()
    importJSONSeedData()
    
  }
  
  func showDefaultMapView(){
    let env = AGSEnvelope(
      xmin: long - envelopeDelta,
      ymin: lat - envelopeDelta,
      xmax: long + envelopeDelta,
      ymax: lat + envelopeDelta,
      spatialReference: AGSSpatialReference.wgs84SpatialReference()
    )
    
    self.mapView.zoomToEnvelope(env, animated: true)
  }
  
  func importJSONSeedData() {
    let jsonURL = NSBundle.mainBundle().URLForResource("attractions", withExtension: "json")
    let jsonData = NSData(contentsOfURL: jsonURL!)
    
    var error: NSError? = nil
    let jsonDict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: nil, error: &error) as! NSDictionary
    
    
    let jsonArray = jsonDict.valueForKeyPath("attractions") as! NSArray
    let blueMarker = AGSPictureMarkerSymbol(imageNamed: "bluePin")
    
    for jsonDictionary in jsonArray {
      if let lat = jsonDictionary.valueForKey("latitude") as? String,
        long = jsonDictionary.valueForKey("longitude") as? String {
          
          var attr = Dictionary<String,String>()
          
          if let title = jsonDictionary.valueForKey("attraction") as? String {
            attr["attraction"] = title
          } else {
            attr["attraction"] = " "
          }
          
          if let description = jsonDictionary.valueForKey("description") as? String {
            attr["description"] = description
          } else {
            attr["description"] = " "
          }
          
          let pointString = "\(lat) , \(long)"
          let point = AGSPoint(fromDecimalDegreesString: pointString, withSpatialReference: AGSSpatialReference.webMercatorSpatialReference())
          self.graphic = AGSGraphic(geometry: point, symbol:blueMarker  as AGSSymbol, attributes: attr)
          self.graphicsLayer.addGraphic(self.graphic)
          
      }
      
    }
    
  }
  
  
  func callout(callout: AGSCallout!, willShowForFeature feature: AGSFeature!, layer: AGSLayer!, mapPoint: AGSPoint!) -> Bool {
    mapView.callout.title = feature.attributeAsStringForKey("attraction")
    mapView.callout.detail = feature.attributeAsStringForKey("description")
    return true
  }
  
  func calloutConfiguration(){
    mapView.callout.accessoryButtonHidden = true
    mapView.callout.titleColor = UIColor.blueColor()
    mapView.callout.detailColor = UIColor.blackColor()
  }
  
}

