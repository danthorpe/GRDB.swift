#if swift(>=5.0)
/// :nodoc:
public struct SQLInterpolation: StringInterpolationProtocol {
    var buildSteps: [(_ sql: inout String, _ context: inout SQLGenerationContext) -> ()] = []

    public init(literalCapacity: Int, interpolationCount: Int) {
        // TODO: use capacity
    }

    /// "SELECT * FROM player"
    public mutating func appendLiteral(_ literal: String) {
        buildSteps.append { (sql, context) in
            sql += literal
        }
    }

    /// "SELECT * FROM \(raw: "player")"
    public mutating func appendInterpolation(sql: String, arguments: StatementArguments = StatementArguments()) {
        appendInterpolation(SQLString(sql: sql, arguments: arguments))
    }

    /// "SELECT * FROM player WHERE \(condition)"
    public mutating func appendInterpolation(_ sqlString: SQLString) {
        // TODO: extend capacity
        buildSteps.append(contentsOf: sqlString.buildSteps)
    }
}
#endif
