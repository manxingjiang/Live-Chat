app = require './app.coffee'
server = require('http').createServer(app)
io = require('socket.io')(server)

sessionConfig = require './session-config.coffee'

io.use (socket, next)->
	req = socket.handshake
	res = {}
	sessionConfig.cookieParser(req, res, (err)->
		if err
			return next(err)
		sessionConfig.sessionStore(req, res, next)
	)

allUser = {}
liveUser = {}
offlinelist = {}
userNumbers = 0
hopeConnect = null

io.on 'connection', (socket)->
	user = socket.handshake.session.user
	if user
		#判断用户是否登录
		name = user.name
		#相应用户的刷新页面事件
		socket.on 'join', (gravatar)->
			userData =
				name : name
				gravatar : gravatar
			#如果用户在待离线列表中，把该用户从待离线列表中删除
			if offlinelist.hasOwnProperty(name)
				delete offlinelist[name]
				clearTimeout(hopeConnect)
			#如果在线用户列表中不存在该用户，则添加到在线用户列表中
			if allUser.hasOwnProperty(name)
			else
				allUser[name] = userData
				liveUser[name] = socket
				++userNumbers
			#向所有socket客户端广播这条此用户的登录信息
			socket.broadcast.emit 'new user',{
				allUser: allUser
				userNumbers: userNumbers
			}

			socket.emit 'success login', {
				allUser: allUser
				userNumbers: userNumbers
			}
		socket.on 'new message', (messageData)->
			socket.broadcast.emit 'message', messageData
			socket.emit 'send message', messageData

		socket.on 'private chat', (data)->
			console.log data

			liveUser[data.name].emit 'private message', data

		socket.on 'disconnect', ->
			#防抖操作：用户刷新页面不算离开，关掉页面三秒之后才算离开
			offlinelist[name] = name
			delay = (ms, func) -> setTimeout func, ms
			hopeConnect =  delay 3000, ->
				console.log "welcome back"
				delete allUser[name]
				--userNumbers

				socket.broadcast.emit 'user left', {
					allUser: allUser
					userNumbers: userNumbers
				}

	#如果用户没有登录，断开socket连接
	else
		socket.disconnect()

module.exports = (server)->
	io.listen(server)
