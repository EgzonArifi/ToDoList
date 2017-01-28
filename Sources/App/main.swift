import Vapor
import HTTP
import Foundation


let drop = Droplet()

drop.get("index") { request in
    return try drop.view.make("index",["message":"Hello World"])
}

drop.get("milk", Int.self, String.self) { request, liters, person in
    return try JSON (node: [
        "message": "Take one downd, pass it around, \(liters - 10) bootles of milk on the wall",
        "name": "Milk from \(person)"])
}

drop.post("post") { request in

    guard let name = request.data["name"]?.string else{
        throw Abort.badRequest
    }
    return try JSON(node: ["message": "Helloo \(name)"])

}

drop.get("template") { request in
    let users =  try [
        ["name": "Egzon", "email": "egzonarifi@gmail.com"].makeNode(),
        ["name": "John", "email": "egzonarifi@gmail.com"].makeNode(),
        ["name": "Joe", "email": "egzonarifi@gmail.com"].makeNode(),
        ["name": "William", "email": "egzonarifi@gmail.com"].makeNode()
    ].makeNode()

    return try drop.view.make("index", Node(node: ["user": users]))
}

drop.run()












