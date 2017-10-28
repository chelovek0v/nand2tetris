class Operation
	attr_accessor :value
	attr_reader :name

	def initialize(value)
		@value = value
	end

	def to_s
		value
  end

  def eql?(obj) # TODO: Add protected specifier
    self.value == obj.value
  end

  def hash
    value.hash
  end
end

class Label < Operation
	def name
		value[1..-2] # "(NAME)" = > "NAME"
	end
end

class AInstruction < Operation
	def name
		value[1..-1] # "@NAME" = > "NAME"
	end

	def constant?
		value =~ /^@[\d]+$/
	end
end

class CInstruction < Operation
	attr_reader :comp
	attr_reader :dest
	attr_reader :jump

	def initialize(value = '')
		super(value)

    @dest = ''
    @jump = ''

		@dest = value.partition('=')[0] if value.include?('=')
		@jump = value.partition(';')[-1] if value.include?(';')

		@comp = value.sub(";" + @jump.to_s, "")
		@comp = @comp.sub(@dest.to_s + "=", "")
	end

	def name
		value
	end
end