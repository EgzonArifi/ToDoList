import Vapor
import VaporSQLite
import HTTP
import Foundation


let drop = Droplet()

drop.get("index") { request in
    return try drop.view.make("index",["message":"Hello World"])
}

drop.run()
