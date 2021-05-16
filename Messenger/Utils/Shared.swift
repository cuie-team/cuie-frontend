//
//  Shared.swift
//  Messenger
//
//  Created by alongkot on 29/4/2564 BE.
//

import Foundation

class Shared {
    static let url: String = "http://35.213.134.44:3000"
    static var name: String = ""
    
    static func decodeStatus(status: String) -> String? {
        switch status {
        case "professor":
            return "Researcher"
        case "student2":
            return "2nd Student"
        case "student3":
            return "3rd Student"
        case "student4":
            return "4th Student"
        case "studentM":
            return "M.Eng"
        case "studentD":
            return "Ph.D"
        case "staffA":
            return "Administrative staff"
        case "staffL":
            return "Labratory staff"
        case "staff":
            return "Staff"
        default:
            return nil
        }
    }
    
    static func mapStatus(status: String?) -> String? {
        switch status {
        case "Researcher":
            return "professor"
        case "2nd Student":
            return "student2"
        case "3rd Student":
            return "student3"
        case "4th Student":
            return "student4"
        case "M.Eng":
            return "studentM"
        case "Ph.D":
            return "studentD"
        case "Administrative staff":
            return "staffL"
        case "Labratory staff":
            return "staffA"
        default:
            return nil
        }
    }
    
}
