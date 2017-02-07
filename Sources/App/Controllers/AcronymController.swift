import Vapor
import HTTP
import VaporPostgreSQL

final class AcronymConroller {

    func addRoutes(drop: Droplet) {
        let acronymBasic = drop.grouped("acronym")
        acronymBasic.get("version", handler:version)
        drop.get("acronym", handler:indexView)
        drop.get("edit", handler:editView)
        acronymBasic.post("create", handler:create)
        acronymBasic.post("addAcronym", handler:addAcronym)
        acronymBasic.get("getAll",handler:getAll)
        acronymBasic.get("first", handler: first)
        acronymBasic.get("afks", handler: afks)
        acronymBasic.get("not-afks", handler: notAfks)
        acronymBasic.get("update", handler: update)
        drop.post("acronym", Acronym.self, "deleteAcronym", handler: deleteAcronym)
    }

    func version(request: Request) throws -> ResponseRepresentable {
        if let db = drop.database?.driver as? PostgreSQLDriver {
            let version = try db.raw("SELECT version()")
            return try JSON(node: version)
        } else {
            return "No db connection"
        }
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.all().makeNode()
        let parameters = try Node(node: [
            "acronyms": acronyms,
            ])
        return try drop.view.make("index", parameters)
    }

    func editView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.query().first()?.makeNode()
        let parameters = try Node(node: [
            "acronyms": acronyms,
            ])
        return try drop.view.make("edit", parameters)
    }
    func create(request: Request) throws -> ResponseRepresentable {
        var acronym = try Acronym(node: request.json)
        try acronym.save()
        return acronym
    }

    func addAcronym(request: Request) throws -> ResponseRepresentable {

        guard let short = request.data["short"]?.string, let long = request.data["long"]?.string else {
            throw Abort.badRequest
        }

        var acronym = Acronym(short: short, long: long)
        try acronym.save()

        return Response(redirect: "/acronym")
    }
    func deleteAcronym(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        try acronym.delete()
        return Response(redirect: "/acronym")
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
