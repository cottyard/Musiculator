var libpath = require('path'),
    http = require("http"),
    fs = require('fs'),
    url = require("url"),
    mime = require('mime');

var ipaddress = process.env.OPENSHIFT_NODEJS_IP || '127.0.0.1';
var port = process.env.OPENSHIFT_NODEJS_PORT || 8080;
var pushStateDisabled = true;

var requestHandler = function (request, response) {

    var uri = url.parse(request.url).pathname;
    var filename = libpath.join('.', uri);

    fs.exists(filename, function (exists) {
        if (!exists) {
            if( pushStateDisabled ) {
                response.writeHead(404, {
                    "Content-Type": "text/plain"
                });
                response.write("404 Not Found\n");
                response.end();
                return;
            } else {
                filename = libpath.join(path, '/index.html');
            }
        }

        if (fs.statSync(filename).isDirectory()) {
            filename += '/index.html';
        }

        fs.readFile(filename, "binary", function (err, file) {
            if (err) {
                response.writeHead(500, {
                    "Content-Type": "text/plain"
                });
                response.write(err + "\n");
                response.end();
                return;
            }

            var type = mime.lookup(filename);
            response.writeHead(200, {
                "Content-Type": type
            });
            response.write(file, "binary");
            response.end();
        });
    });
};

var server = http.createServer();
server.addListener('request', requestHandler);
server.listen(port, ipaddress);

console.log("Static file server running at\n" +
    "=> http://localhost:" + port + "/\n" + 
    "CTRL + C to shutdown");