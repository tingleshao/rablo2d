class EzXmlNode
	# public variables
	attr_accessor :name, :attribute, :childNodes, :indent, :cont, :level
	
	def initialize(name, attribute, indent, level)
		@name = name
		@indent = indent
		@attribute = attribute
		@childNodes = []
		@level = level
		@cont = ''
	end
	
	def addChildNode(cnodeName, cnodeAttribute)
		# need to support add by node object later..
		cNode = EzXmlNode.new(cnodeName, cnodeAttribute, @indent , @level + 1)
		@childNodes << cNode
		puts "add child node \"" + cnodeName + "\" to \"" + @name + "\" OK"
	#	puts "child nodes: " + @childNodes.to_s
	#	updateChildNodeLevel()
	end

	def updateChildNodeLevel()
		if @childNodes.size > 0
			for i in 0..@childNodes.size-1
			#	puts @level
				@childNodes[i].indent = @indent
				@childNodes[i].level = @level + 1
			#	puts @childNodes[i].level
				@childNodes[i].updateChildNodeLevel()
			end
		end
	end

	def  to_s()
		@cont = ''
		# may support "child node stuff before self attribute" later! << this is an important thing
		@cont += " " * ( @indent * @level )
		@cont += ('<' +@name + '>')
		@cont += "\n"
		if (@attribute.size > 0)
			@cont += " " * ( @indent * ( @level + 1 ) )
			@cont += @attribute
		end
#		puts "child nodes: " + @childNodes.to_s
		if @childNodes.size > 0 
			for i in 0..@childNodes.size
				@cont += "\n"
				@cont += @childNodes[i].to_s
			end
		end
		if (@attribute.size > 0)
			@cont += "\n"
		end
		@cont += " " * ( @indent * @level )
		@cont += ("<\\" + @name  + '>')	
		# this piece of regular expression matches the line with only one newline character
		@cont = @cont.gsub /^$\n/, ''
		return @cont
	end	
end