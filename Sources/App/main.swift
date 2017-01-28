import Vapor
import VaporSQLite
import HTTP
import Foundation


let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

let controller = TasksViewController()
controller.addRoutes(drop: drop)

drop.post("tasks","delete") { request in
    
    guard let taskId = request.data["taskId"]?.int else {
        throw Abort.badRequest
    }
    
    let result = try drop.database?.driver.raw("DELETE FROM Tasks WHERE taskId = ?",[taskId])
    
    return Response(redirect: "/tasks/all")

}

drop.post("tasks") { request in
    
    guard let title = request.data["title"]?.string else {
        throw Abort.badRequest
    }
    
    let result = try drop.database?.driver.raw("INSERT INTO Tasks(title) VALUES(?)",[title])
    
    return Response(redirect: "/tasks/all")
}


drop.get("tasks","all") { request in
    
    let result = try drop.database?.driver.raw("SELECT taskId, title from Tasks;")
    
    guard let nodes = result?.nodeArray else {
        return try JSON(node :[])
    }
    
    let tasks = nodes.flatMap(Task.init)
    
    return try drop.view.make("index",Node(node: ["tasks":tasks.makeNode()]))
    
}

drop.get("index") { request in
    return try drop.view.make("index",["message":"Hello World"])
}

drop.run()
