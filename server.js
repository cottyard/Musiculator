var libpath = require('path'),
    http = require('http'),
    fs = require('fs'),
    url = require('url'),
    mime = require('mime');

var ipaddress = process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1';
var port = process.env.OPENSHIFT_NODEJS_PORT || 8080;

var request_handler = function (request, response) {

    var respond_file_not_found = function(){
        response.writeHead(404, {
            "Content-Type": "text/plain"
        });
        response.write("404 Not Found\n");
        response.end();
    };
    
    var respond_server_error = function(err){
        response.writeHead(500, {
            "Content-Type": "text/plain"
        });
        response.write(err + "\n");
        response.end();
    };
    
    var respond_succeed = function(type, file){
        response.writeHead(200, {
            "Content-Type": type
        });
        response.write(file, "binary");
        response.end();
    };
    
    var send_file = function(filename) {
        if (fs.statSync(filename).isDirectory()) {
            filename += '/index.html';
        }

        fs.readFile(filename, "binary", function (err, file) {
            if (err) {
                respond_server_error(err);
                return;
            }
            var type = mime.lookup(filename);
            respond_succeed(type, file);
            return;
        });
    };
    
    var uri = url.parse(request.url).pathname;
    var filename = libpath.join('.', uri);
    
    fs.exists(filename, function (exists) {
        if(!exists){
            respond_file_not_found();
            return;
        }
        send_file(filename);
    });
};

var server = http.createServer();
server.addListener('request', request_handler);
server.listen(port, ipaddress);

console.log("Static file server running at\n" +
    "=> http://localhost:" + port + "/\n" + 
    "CTRL + C to shutdown");