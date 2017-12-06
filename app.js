var http = require("http")
var path = require('path')
var express = require('express')
var exec = require("child_process").exec
var app = express()

app.use(express.static(path.join(__dirname, 'public')));

function sendBashCommand (error, req, res){
  if (error) {
    console.log(error)
    res.sendStatus(500)
  }else{
    exec('sh lib/' + req.params.param1 + '.sh', function(error, stdout, stderr){
    	console.log(stdout);
    })
    res.sendStatus(200)
  }
}

function sendBashCommand1 (error, req, res){
  if (error) {
    console.log(error)
    res.sendStatus(500)
  }else{
    exec('sh lib/raspi-control.sh ' + req.params.param1, function(error, stdout, stderr){
    	console.log(stdout);
    })
    res.sendStatus(200)
  }
}
function sendBashCommand2 (error, req, res){
  if (error) {
    console.log(error)
    res.sendStatus(500)
  }else{
    exec('sh lib/raspi-control.sh ' + req.params.param1 + " " + req.params.param2, function(error, stdout, stderr){
    	console.log(stdout);
    })
    res.sendStatus(200)
  }
}
function sendBashCommand3 (error, req, res){
  if (error) {
    console.log(error)
    res.sendStatus(500)
  }else{
    exec('sh lib/raspi-control.sh ' + req.params.param1 + " " + req.params.param2 + " " + req.params.param3, function(error, stdout, stderr){
    	console.log(stdout);
    })
    res.sendStatus(200)
  }
}

app.get('/_alive', function(req, res){
  res.send('OK');
})
app.get('/', function(req, res){
  res.sendfile('index.html');
})
app.get('/0/:param1', function(req, res){
  error = null
  sendBashCommand(error, req, res)
})
app.get('/1/:param1', function(req, res){
  error = null
  sendBashCommand1(error, req, res)
})
app.get('/2/:param1/:param2', function(req, res){
  error = null
  sendBashCommand2(error, req, res)
})
app.get('/3/:param1/:param2/:param3', function(req, res){
  error = null
  sendBashCommand3(error, req, res)
})

app.listen(8282);
