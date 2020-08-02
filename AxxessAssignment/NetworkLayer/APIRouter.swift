//
//  APIRouter.swift
//  Jaarx
//
//  Created by Sumit Kumar on 14/06/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
import Alamofire

protocol APIRouter: URLRequestConvertible {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var url: URL { get }
    var encoding: ParameterEncoding { get }
    var version: String { get }
}

extension APIRouter {
    
    var baseURL: String {
        return "https://raw.githubusercontent.com/"
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type": "application/json","os":"iOS"]
    }
    
    var version: String {
        return ""
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var url: URL {
           switch httpMethod {
           case .get:
               var parameterString : String?
               if (parameters != nil) {
                   parameterString = Helper.makeUrlWithParameters(parameters!)
               }
               return URL.init(string: self.baseURL + self.path + (parameterString ?? ""))!
           default:
               return URL.init(string: self.baseURL + self.path)!
           }
       }

       
       func asURLRequest() throws -> URLRequest {
           var urlRequest = URLRequest.init(url: self.url)
           urlRequest.httpMethod = httpMethod.rawValue
//           urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.headers = headers!
           if httpMethod == .post{
               if let parameters = parameters {
                   let jsonData = Helper.makeHttpBodyWithParameters(parameters)
                   if let bodyData = jsonData {
                       urlRequest.httpBody = bodyData
                   }
               }
           }
           return urlRequest
       }
}
