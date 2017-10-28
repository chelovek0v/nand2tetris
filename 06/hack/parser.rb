require './operation.rb'
require 'set'

class Parser
	attr_accessor :input_file
	attr_reader :conveyor
	attr_reader :labels
	attr_reader :variables

	def initialize(input_file)
		raise ArgumentError, 'input_file must not be nil' unless input_file

		@input_file = input_file
		@variables = Set.new()
    @conveyor = []
    @labels = {}
	end

	def parse
		unless File.zero?(input_file)
			File.readlines(input_file).each do |line|
				stripped_line = strip(line)
				conveyor << CInstruction.new(stripped_line) if c_instruction?(stripped_line)
				conveyor << AInstruction.new(stripped_line) if a_instruction?(stripped_line)
				conveyor << Label.new(stripped_line) if label?(stripped_line)
			end

			parse_labels
			parse_variables
		end

		yield conveyor
	end

	def to_s
		puts "Conveyor:"
		puts conveyor
		puts "Variables:"
		puts variables.to_a.to_s
		puts "Labels:"
		puts labels.to_s
	end

  private

  attr_writer :conveyor
  attr_writer :labels
  attr_writer :variables

  def strip(str)
    str.strip.delete(' ').split('//')[0]
  end

  def parse_labels
    conveyor.each_with_index do |instruction, index|
      reference_line = index - labels.count # ignore labels in conveyor
      labels[instruction.name] = reference_line if instruction.kind_of?(Label)
    end
  end

  def parse_variables
    variables_array = conveyor.select { |instruction| instruction.kind_of?(AInstruction) && !labels[instruction.name] } # ignore labels' variables
    self.variables = variables_array.to_set
  end

  def instruction?(str)
    label?(str) || a_instruction?(str) || c_instruction?(str)
  end

  def label?(str)
    !!(str =~ /^\([A-Za-z_0-9.$]+\)$/) # TODO: replace with a shared regexp const
  end

  def c_instruction?(str)
    !!(str =~ /^([mdMAaD])*=?([dmaDMA+\-10!&|])+;?([JNLGTEMP])*$/)
  end

  def a_instruction?(str)
    variable?(str) || a_instruction_constant?(str)
  end

  def variable?(str)
    !!(str =~ /^@[A-Za-z_0-9.$]+$/)
  end

  def a_instruction_constant?(str)
    !!(str =~ /^@[\d]+$/)
  end
end
