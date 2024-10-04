const std = @import("std");
const net = std.net;
const http = std.http;

pub fn main() !void {
    const port: u16 = 4000;

    const addr = net.Address.parseIp4("127.0.0.1", port) catch |err| {
        std.debug.print("An error occurred while resolving the IP address: {}\n", .{err});
        return;
    };

    var server = addr.listen(.{}) catch |err| {
        std.debug.print("An error occurred while listening: {}\n", .{err});
        return;
    };

    std.debug.print("Accepting requests on 127.0.0.1:{} \n", .{port});

    start_server(&server);
}

fn start_server(server: *net.Server) void {
    while (true) {
        var connection = server.accept() catch |err| {
            std.debug.print("Error accepting connection: {}\n", .{err});
            return;
        };

        defer connection.stream.close();

        var read_buffer: [1024]u8 = undefined;
        var http_server = http.Server.init(connection, &read_buffer);

        var request = http_server.receiveHead() catch |err| {
            std.debug.print("Could not read head: {}\n", .{err});
            continue;
        };

        handle_request(&request) catch |err| {
            std.debug.print("Could not handle request: {}", .{err});
            continue;
        };
    }
}

fn handle_request(request: *http.Server.Request) !void {
    std.debug.print("Handling request for {s}\n", .{request.head.target});
    try request.respond("Hello http!\n", .{});
}
