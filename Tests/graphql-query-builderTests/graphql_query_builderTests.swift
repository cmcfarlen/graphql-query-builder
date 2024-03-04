import XCTest
@testable import GraphQLQueryBuilder

final class graphql_query_builderTests: XCTestCase {
    func testExample() throws {
        let q = query {
            "foo"
            "bar"
            "baz"
        }

        XCTAssertEqual("""
        query { foo bar baz }
        """, q.description)

    }

    func testObject() throws {
        let q = query {
            object("foo") {
                "bar"
                "baz"
            }
        }

        XCTAssertEqual("""
        query { foo { bar baz } }
        """, q.description)

    }

    func testObjectParams() throws {
        let q: Query = query {
            object("foo", withParms: ["bar": "42"]) {
                "bar"
                "baz"
            }
        }

        XCTAssertEqual("""
        query { foo { bar baz } }
        """, q.description)

    }

    func testTemplate() throws {
        struct Foo: Queryable {
            var bar: String?
            var baz: String?

            var query: [Query] {
                object("foo") {
                    if bar != nil {
                        "bar"
                    }
                    if baz != nil {
                        "baz"
                    }
                }
            }
        }

        let q = query {
            Foo(bar: "bar")
        }

        XCTAssertEqual("""
        query { foo { bar } }
        """, q.description)

    }
}
