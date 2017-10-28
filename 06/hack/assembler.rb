require './parser.rb'
require './operation.rb'

class Assembler
  SYM_TABLE = {
      :R0 => 0,
      :R1 => 1,
      :R2 => 2,
      :R3 => 3,
      :R4 => 4,
      :R5 => 5,
      :R6 => 6,
      :R7 => 7,
      :R8 => 8,
      :R9 => 9,
      :R10 => 10,
      :R11 => 11,
      :R12 => 12,
      :R13 => 13,
      :R14 => 14,
      :R15 => 15,
      :SCREEN => 16384,
      :KBD => 24576,
      :SP => 0,
      :LCL => 1,
      :ARG => 2,
      :THIS => 3,
      :THAT => 4
  }

  DEST_TABLE = {
      '' => '000',
      'M' => '001',
      'D' => '010',
      'MD' => '011',
      'A' => '100',
      'AM' => '101',
      'AD' => '110',
      'AMD' => '111'
  }

  COMP_TABLE = {
      #when a = 0
      '0' => '0101010',
      '1' => '0111111',
      '-1' => '0111010',
      'D' => '0001100',
      'A' => '0110000',
      '!D' => '0001101',
      '!A' => '0110001',
      '-D' => '0001111',
      '-A' => '0110011',
      'D+1' => '0011111',
      'A+1' => '0110111',
      'D-1' => '0001110',
      'A-1' => '0110010',
      'D+A' => '0000010',
      'D-A' => '0010011',
      'A-D' => '0000111',
      'D&A' => '0000000',
      'D|A' => '0010101',
      #when a = 1
      'M' => '1110000',
      '!M' => '1110001',
      '-M' => '1110011',
      'M+1' => '1110111',
      'M-1' => '1110010',
      'D+M' => '1000010',
      'D-M' => '1010011',
      'M-D' => '1000111',
      'D&M' => '1000000',
      'D|M' => '1010101'
  }

  JUMP_TABLE = {
      '' => '000',
      'JGT' => '001',
      'JEQ' => '010',
      'JGE' => '011',
      'JLT' => '100',
      'JNE' => '101',
      'JLE' => '110',
      'JMP' => '111'
  }

  attr_accessor :input_file
  attr_reader :parser
  attr_reader :variables
  attr_reader :output
  attr_reader :variable_counter

  def initialize(input_file)
    raise ArgumentError, 'input_file must not be nil' unless input_file

    @input_file = input_file
    @parser = Parser.new(input_file)
    @output = []
    @variables = {}
    @variable_counter = 16
  end

  def assembly
    parser.parse do |conveyor|
      conveyor.each do |instruction|
        output << try_convert_a_instruction(instruction) if instruction.kind_of?(AInstruction)
        output << try_convert_c_instruction(instruction) if instruction.kind_of?(CInstruction)
      end
    end

    yield output
  end

  def to_s
    puts parser.to_s
    puts "Output: "
    puts output
  end

  private

  attr_writer :variable_counter

  def try_convert_c_instruction(instruction)
    code = '111'
    
    code << Assembler::COMP_TABLE[instruction.comp]

    code << Assembler::DEST_TABLE[instruction.dest]

    code << Assembler::JUMP_TABLE[instruction.jump]
  end

  def try_convert_a_instruction(instruction)
    instruction_name = instruction.name
    instruction_value = instruction.value

    return '0' + normalized_binary(instruction_name) if instruction.constant?

    return '0' + normalized_binary(Assembler::SYM_TABLE[instruction_name.to_sym]) if Assembler::SYM_TABLE.has_key?(instruction_name.to_sym)

    return '0' + normalized_binary(parser.labels[instruction_name]) if parser.labels.has_key?(instruction_name)

    return variables[instruction_value] if variables.has_key?(instruction_value)

    if !parser.labels.has_key?(instruction_name)
      code = variables[instruction_value] = '0' + normalized_binary(variable_counter)
      self.variable_counter = variable_counter + 1
      return code
    end
  end

  def normalized_binary(input)
    input.to_i.to_s(2).rjust(15, '0')
  end
end

begin
  input_file = ARGV[0]
  output_file = ARGV[1] || "output.hack"

  assembler = Assembler.new(input_file)
  assembler.assembly do |output|
    puts "Writing to file... ", output_file
    output_file = File.open(output_file, 'w')
    output.each do |line|
      output_file.puts(line)
    end
    output_file.close
  end
rescue => e
  puts e.message
end

