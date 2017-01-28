import Vapor
import HTTP
import VaporPostgreSQL
import Foundation


let drop = Droplet(
    preparations: [Acronym.self],
    providers: [VaporPostgreSQL.Provider.self]
)

drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    } else {
        return "No db connection"
    }
}
drop.post ("new") { request in
    var acronym = try Acronym(node: request.json)
    try acronym.save()
    return acronym
}
drop.get ("test") { request in
    var acronym = Acronym(short: "AFK", long: "Away From Keyboard")
    try acronym.save()
    return try JSON(node: Acronym.all().makeNode())
}
drop.get("model") { request in
    let acronym = Acronym(short: "AFK", long: "Away From Keyboard")
    return try acronym.makeJSON()
}

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












