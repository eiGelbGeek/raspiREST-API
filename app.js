var spawn   = require('child_process').spawn;
var express = require('express');
var path = require('path')
var http = require("http")
var app     = express();

app.use(express.static(path.join(__dirname, 'public')));

app.get('/raspi', function(req, res) {
  var cmd = spawn(__dirname + '/lib/raspi-control.sh', [ req.query.v1, req.query.v2, req.query.v3 ]);
  var output  = [];

  cmd.stdout.on('data', function(data) {
    output.push(data);
  });

  cmd.on('close', function(code) {
    if (code === 0)
      res.sendStatus(200);
    else
      res.sendStatus(500);
  });
});

app.listen(8282);
