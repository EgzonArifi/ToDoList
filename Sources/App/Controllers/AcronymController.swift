import Vapor
import HTTP
import VaporPostgreSQL

final class AcronymConroller {

    func addRoutes(drop: Droplet) {
        let acronymBasic = drop.grouped("acronym")
        acronymBasic.get("version", handler:version)
        acronymBasic.post("create", handler:create)
        acronymBasic.get("getAll",handler:getAll)
        acronymBasic.get("first", handler: first)
        acronymBasic.get("afks", handler: afks)
        acronymBasic.get("not-afks", handler: notAfks)
        acronymBasic.get("update", handler: update)
        acronymBasic.get("delete-afks", handler: deleteAfks)
    }

    func version(request: Request) throws -> ResponseRepresentable {
        if let db = drop.database?.driver as? PostgreSQLDriver {
            let version = try db.raw("SELECT version()")
            return try JSON(node: version)
        } else {
            return "No db connection"
        }
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var acronym = try Acronym(node: request.json)
        try acronym.save()
        return acronym
    }

    func getAll(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.all().makeNode())
    }

    func first(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.query().first()?.makeNode())
    }

    func afks(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.query().filter("short", "AFK").all().makeNode())
    }

    func notAfks(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Acronym.query().filter("short", .notEquals, "AFK").all().makeNode())
    }

    func update(request: Request) throws -> ResponseRepresentable {
        guard var first = try Acronym.query().first(),
            let long = request.data["long"]?.string else {
                throw Abort.badRequest
        }
        first.long = long
        try first.save()
        return first

    }

    func deleteAfks(request: Request) throws -> ResponseRepresentable {
        let query = try Acronym.query().filter("short", "AFK")
        try query.delete()
        return try JSON(node: Acronym.all().makeNode())
    }

}
