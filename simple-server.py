from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

playerNames = {}

class Player:
	name = ''
	instrument = 2
	xLoc = 0

	def __init__(self, name):
		self.name = name


class IphoneChat(Protocol):

	name = ''
	instrument = ''
	xLoc = 2
	noteOn = 0

	def connectionMade(self):
		self.factory.clients.append(self)
		# if (len(playerNames) > 0):
		# 	for playerName in playerNames:
		# 		player = playerNames[self]
		# 		print 'MESSAGING' + player.name
		# 		self.message(playerName)
		message = 'OTHERPLAYERS'
		for c in self.factory.clients:
			if (c != self and c.name != ''):
				message += ':' + c.name + ':' + c.instrument + ':' + `c.xLoc`
				#self.message("OTHERPLAYERS" + c.name + ':' + `c.instrument` + ':' + `c.xLoc`)
		if (message != 'OTHERPLAYERS'):
			self.message(message)
		#if (len(self.factory.clients) >= 2):
		#	for c in self.factory.clients:
		#		c.message("ready");
		print "clients are ", self.factory.clients

	def connectionLost(self, reason):
		self.factory.clients.remove(self)

	def dataReceived(self, data):
		print data
		if (data.find('NEWPLAYER:') != -1):
			splitRes = (data.split(':'))
			self.name = splitRes[1]#data[len('NEWPLAYER:'):]
			self.instrument = splitRes[2]
		elif (data.find('CHANGEINSTRUMENT:') != -1):
			splitRes = (data.split(':'))
			instrument = splitRes[1]
			self.instrument = instrument
			data = "CHANGEINSTRUMENT:" + self.name + ':' + self.instrument
		elif (data.find('CHANGEXLOC:') != -1):
			splitRes = (data.split(':'))
			xLoc = splitRes[1]
			self.xLoc = float(xLoc)
			data = "CHANGEXLOC:" + self.name + ':' + `self.xLoc`
		elif (data.find('CHANGENOTEON:') != -1):
			splitRes = (data.split(':'))
			self.noteOn = int(splitRes[1])
			data = "CHANGENOTEON:" + self.name + ':' + `self.noteOn`

		for c in self.factory.clients:
			if (c != self):
				c.message(data)
		#a = data.split(':')
		#print a

	def message(self, message):
		self.transport.write(message)# + '\r\n')


factory = Factory()
factory.clients = []
factory.protocol = IphoneChat
reactor.listenTCP(80, factory)
print "Iphone Chat server started"
reactor.run()
