import Vapor

final class DynamicTicketQueue {
    private let queue = DispatchQueue(label: "dynamicTicketQueue", attributes: .concurrent)
    private var currentTicket: Int = 0

    func requestTicket() -> Int {
        return queue.sync(flags: .barrier) {
            currentTicket += 1
            return currentTicket
        }
    }
}

let ticketQueue = DynamicTicketQueue()

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("ticket") { req async throws -> Response in
        let ticketNumber = ticketQueue.requestTicket()
        let response = ["ticket": ticketNumber]
        return Response(status: .ok, body: .init(string: "\(ticketNumber)"))
    }
}
