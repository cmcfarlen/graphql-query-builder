// The Swift Programming Language
// https://docs.swift.org/swift-book

protocol Queryable {
    var query: [Query] { get }
}

@resultBuilder
struct QueryBuilder {
    static func buildBlock() -> [Query] {
        []
    }
    static func buildBlock(_ parts: Queryable...) -> [Query] {
        parts.flatMap { $0.query }
    }

    static func buildIf(_ value: Queryable?) -> [Query] {
        value?.query ?? []
    }
}

protocol QueryActualParameter {
    var parameterType: String? { get }
    var parameterName: String { get }
}

extension QueryActualParameter {
    var parameterType: String? { nil }
}

extension String: QueryActualParameter {
    var parameterName: String { self }
}


enum Query {
    case query(items: [Query])
    case field(name: String)
    case object(name: String, parameters: [String: QueryActualParameter], fields: [Query])
}

extension Query: CustomStringConvertible {
    var description: String {
        switch self {
            case .query(let items):
                return "query { \(items.map(\.description).joined(separator: " ")) }"
            case .field(let name):
                return name
            case .object(let name, let parameters, let fields):
                return if parameters.isEmpty {
                    "\(name) { \(fields.map(\.description).joined(separator: " ")) }"
                } else {
                    "\(name)(\(parameters.map { $0.key + ":" + $0.value.parameterName }.joined(separator: ", "))) { \(fields.map(\.description).joined(separator: " ")) }"
                }
        }
    }
}

extension Query: Queryable {
    var query: [Query] {
        [self]
    }
}

extension Array: Queryable where Element == Query {
    var query: [Query] {
        self
    }
}

func query(@QueryBuilder content: () -> [Query]) -> Query {
    .query(items: content())
}

func object(_ name: String, withParms parameters: [String:QueryActualParameter] = [:], @QueryBuilder content: () -> [Query]) -> [Query] {
    [.object(name: name, parameters: parameters, fields: content())]
}

extension String: Queryable {
    var query: [Query] {
        [.field(name: self)]
    }
}

