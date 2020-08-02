//
//  HomeRouter.swift
//  CavistaAssignement
//
//  Created by Sushant Alone on 01/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
import Alamofire

enum HomeRouter {
    case home
}

extension HomeRouter : APIRouter
{
    var path: String {
        return "AxxessTech/Mobile-Projects/master/challenge.json"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return [:]
    }
    
    
}
