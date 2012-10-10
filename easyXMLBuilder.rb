load 'easyXMLNode.rb'


class EzXmlBuilder
	attr_accessor :indent, :cont, :rootNodeLst, :currentIndex  # may add meta information later
	
	def initialize(indent)
		@indent = indent
		@cont = ''
		@rootNodeLst = []
		@currentIndex = 0
	end
	
	def initialize()
		@indent = 2
		@cont = ''
		@rootNodeLst = []
		@currentIndex = 0
	end
	
	def to_s
		updateCont()
		return @cont
	end

	def addNode(*args)
		if (args.size == 2)
			nodeName = args[0]
			nodeValue = args[1]
			node = EzXmlNode.new(nodeName, nodeValue, @indent, 1)
			@rootNodeLst << [ node , @currentIndex ]
			puts "add root node \"" + nodeName + "\" OK"
			@currentIndex += 1
		#	updateCont()
		elsif (args.size == 1)
			node = args[0]
			node.indent = @indent
			node.level = 1
			node.updateChildNodeLevel()
			@rootNodeLst << [ node, @currentIndex ]
			puts "add root node \"" + node.name + "\" OK"
			@currentIndex += 1
		end
	end
	
	
	def appendToExistingNode(index, nodeName, nodeValue)
		pair = @rootNodeLst[i]
		node = pair[0]
		node.addChildNode(nodeName, nodeValue)
		puts "addpend child node to node " + index.to_s + " OK"
	#	updateCont()
	end
		
	def getNode(index)
		# if user wants to append a node which hierarchy deeper than 1, she needs to call this method
		# may come up with a clever way to do this
		pair = @rootNodeLst[index]
		node = pair[0]
		return node
	end
	
	def updateCont()
		# to string
		@cont = ''
		@cont += ('<root>')
		@cont += "\n"
	#	puts "rootNodeLst size: " + rootNodeLst.size.to_s 
	#	puts rootNodeLst
		if @rootNodeLst.size > 0
			for i in 0..(@rootNodeLst.size-1)
				pair = @rootNodeLst[i]
			#	puts "pair0: " + pair[0].to_s
				@cont += pair[0].to_s
				@cont += "\n"
			end
		end
		@cont += ("<\\root>")	
	#	@cont = @cont.gsub /^$\n/, ''
	end
end