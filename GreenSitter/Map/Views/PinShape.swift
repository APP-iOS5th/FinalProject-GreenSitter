////
////  PinShape.swift
////  GreenSitter
////
////  Created by Yungui Lee on 8/9/24.
////
//
//import Foundation
//import UIKit
//import KakaoMapsSDK
//
//class PinShape: MapViewController {
//    
//    override func addViews() {
//        let defaultPosition: MapPoint = MapPoint(longitude: 126.978365, latitude: 37.566691)
//        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
//        
//        mapController?.addView(mapviewInfo)
//    }
//    override func viewInit(viewName: String) {
//        print("OK")
//        createShape()
//    }
//    
//    
//    func createShape() {
//        let view = mapController?.getView("mapview") as! KakaoMap
//        let manager = view.getShapeManager()
//        let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001, passType: .route)
//        
//        // PolygonShape의 레벨별 스타일을 지정한다.
//        let perLevelStyle = PerLevelPolygonStyle(color: UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0),
//                                                 strokeWidth:2,
//                                                 strokeColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0),
//                                                 level: 0) // 0 ~ 최대레벨까지
//        
//        // PolygonShapeStyle에 레벨별 스타일을 추가한다.
//        let shapeStyle = PolygonStyle(styles: [perLevelStyle])
//        
//        // PolygonShapeStyleSet에 PolygonShapeStyle을 추가한다.
//        let shapeStyleSet = PolygonStyleSet(styleSetID: "shapeLevelStyle", styles: [shapeStyle])
//        manager.addPolygonStyleSet(shapeStyleSet)
//        
//        // PolygonShape 생성옵션.
//        // polygon의 point를 basePosition을 기준으로 하는 상대좌표값으로 구성.
//        let option = PolygonShapeOptions(shapeID: "RectShape", styleID: "shapeLevelStyle", zOrder: 1)
//        let points = Primitives.getRectanglePoints(width: 50, height: 50.5, cw: true) //폴리곤의 외곽선 포인트들. 외곽선 포인트들은 시계방향순으로 구성되어야 한다.
//        let hole = Primitives.getRectanglePoints(width: 20.0, height: 20.0, cw: false) // 폴리곤 안에 구멍을 나타내는 포인트들. 구멍 포인트들은 반시계방향순으로 구성되어야 한다.
//        let polygon = Polygon(exteriorRing: points, hole: hole, styleIndex: 0) // styleIndex: Polygon이 사용할 스타일의 인덱스.
//        
//        option.polygons.append(polygon) //PolygonShape은 여러 개의 Polygon으로 구성될 수 있다.
//        option.basePosition = MapPoint(longitude: 126.9779, latitude: 37.5663)
// //PolygonShape의 기준 위치.
//        let shape = layer?.addPolygonShape(option) { (polygon: PolygonShape?) -> Void in // 레이어에 PolygonShape를 추가한다. add할 때 완료가 됐을 때 받는 콜백 이벤트를 추가할 수 있다. 콜백은 추가한 polygonShape 객체를 파라미터로 사용한다.
//            NSLog("\(polygon!.shapeID) added")
//        }
//        
//        
//        shape?.show()
//        
//        print("Shape is showing: \(String(describing: shape?.isShow))")
//    }
//}
