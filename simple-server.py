from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor

class IphoneChat(Protocol):
	def connectionMade(self):
		self.factory.clients.append(self)
		if (len(self.factory.clients) >= 2):
			for c in self.factory.clients:
				c.message("ready");
		print "clients are ", self.factory.clients

	def connectionLost(self, reason):
		self.factory.clients.remove(self)

	def dataReceived(self, data):
		print 'called'
		#a = data.split(':')
		#print a
 
		for c in self.factory.clients:
			if (c != self):
				#c.message(a[0])
				c.message(data)

	def message(self, message):
		self.transport.write(message)# + '\r\n')


factory = Factory()
factory.clients = []
factory.protocol = IphoneChat
reactor.listenTCP(80, factory)
print "Iphone Chat server started"
reactor.run()
