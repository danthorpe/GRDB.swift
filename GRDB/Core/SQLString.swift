// TODO: documentation
public struct SQLString {
    var buildSteps: [(_ sql: inout String, _ context: inout SQLGenerationContext) -> ()] = []
    
    fileprivate init(buildSteps: [(_ sql: inout String, _ context: inout SQLGenerationContext) -> ()]) {
        self.buildSteps = buildSteps
    }

    public init(sql: String, arguments: StatementArguments = StatementArguments()) {
        self.init(buildSteps: [{ (sql, context) in
            sql += sql
            if !arguments.isEmpty {
                if context.appendArguments(arguments) == false {
                    // GRDB limitation: we don't know how to look for `?` in sql and
                    // replace them with with literals.
                    fatalError("Not implemented")
                }
            }
        }])
    }
    
    public init(_ sqlString: SQLString) {
        self.init(buildSteps: sqlString.buildSteps)
    }
    
    func sql(_ context: inout SQLGenerationContext) -> String {
        var sql = "" // TODO: use capacity
        for step in buildSteps {
            step(&sql, &context)
        }
        return sql
    }
}

extension SQLString {
    public static func + (lhs: SQLString, rhs: SQLString) -> SQLString {
        var result = lhs
        result += rhs
        return result
    }
    
    public static func += (lhs: inout SQLString, rhs: SQLString) {
        lhs.buildSteps.append(contentsOf: rhs.buildSteps)
    }
    
    public mutating func append(_ other: SQLString) {
        self += other
    }

    public mutating func append(sql: String, arguments: StatementArguments = StatementArguments()) {
        self += SQLString(sql: sql, arguments: arguments)
    }
}

// MARK: - ExpressibleByStringInterpolation

#if swift(>=5.0)
extension SQLString: ExpressibleByStringInterpolation {
    /// :nodoc
    public init(unicodeScalarLiteral: String) {
        self.init(sql: unicodeScalarLiteral, arguments: [])
    }
    
    /// :nodoc:
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(sql: extendedGraphemeClusterLiteral, arguments: [])
    }
    
    /// :nodoc:
    public init(stringLiteral: String) {
        self.init(sql: stringLiteral, arguments: [])
    }
    
    /// :nodoc:
    public init(stringInterpolation sqlInterpolation: SQLInterpolation) {
        self.init(buildSteps: sqlInterpolation.buildSteps)
    }
}
#endif
