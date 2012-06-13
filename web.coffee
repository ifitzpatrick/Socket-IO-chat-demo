express  = require 'express'
socketio = require 'socket.io'
sealdeal = require '../sealdeal'

app = express.createServer()

# Configuration

app.configure ->
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router


app.configure ->
  app.use express.static __dirname + '/public'

app.configure 'development', ->
  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', ->
  app.use express.errorHandler()

preprocessor = sealdeal.preprocessorRoute __dirname + '/public', {}

app.get '/*', preprocessor
app.get '/', (req, res, next) ->
  req.params[0] = "/index.html"
  preprocessor req, res, next

app.listen process.env.PORT or 5000
io = socketio.listen app

chat = io.on 'connection', (socket) ->
  socket.on 'message', (msg) ->
    chat.sockets.send msg
