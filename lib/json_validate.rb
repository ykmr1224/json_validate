require "json_validate/version"

module JSONValidate
  class ValidationError < RuntimeError
  end

  def self.pathstr(path)
    "/"+path.join("/")
  end

  # Validate each elements of a hash by the validator.
  def self.validateHash(hash, validator, path=[])
      raise ValidationError.new(pathstr(path) + " : Expected to be a Hash.") unless hash.kind_of? Hash
      validator.each do |key, value|
        raise ValidationError.new(pathstr(path) + " : Key '#{key}' is expected to be exists.") unless hash.include? key.to_s
        path.push(key.to_s)
        validate(hash[key.to_s], value, path)
        path.pop
      end
  end

  # Validate each elements of an array by the first element of validator(validator[0])
  # This expects validator is an array containing only one element. Other than the first element will be ignored
  def self.validateArray(array, validator, path=[])
    raise ValidationError.new(pathstr(path) + " : Expected to be an Array.") unless array.kind_of? Array
    parent = path.pop || "" # to make the path like "/hoge/foo/parent[1]""
    array.each_index do |i|
      path.push(parent+"[#{i}]")
      validate(array[i], validator[0], path)
      path.pop
    end
    path.push parent
  end

  # Validate the parsed JSON object with the validator
  # validator can be a hash or an array
  #  e.g. {id: Fixnum, subject: String, message: String, receipients: [{email: String, name: String}]}
  #  e.g. [String]
  # This throws a ValidationError if the validation failed.
  # If a block is given, validator is ignored and the block is evaluated as the validator to be used
  def self.validate(json, validator=nil, path=[], &block)
    return validate(json, JSONValidate.instance_eval(&block), path) if block_given?

    case validator
    when Hash # validate each pair of the hash
      validateHash(json, validator, path)
    when Array # validate each elements of the array
      validateArray(json, validator, path)
    when Class # validate the type of the value
      raise ValidationError.new(pathstr(path)) unless json.kind_of? validator
    when CustomValidator
      raise ValidationError.new(pathstr(path)) unless validator.validate(json)
    when Regexp
      raise ValidationError.new(pathstr(path)) unless validator =~ json
    when nil
      raise ValidationError.new(pathstr(path)) unless json.nil?
    else
      raise ValidationError.new("Validator is expected to be Hash, Array, or Class.")
    end
  end

  class CustomValidator
    def validate(json, path=[]); false; end
    def message; ""; end
  end

private

  class BooleanValidator < CustomValidator
    def validate(json, path=[])
      json.kind_of?(TrueClass) || json.kind_of?(FalseClass)
    end
  end

  def self.boolean
    BooleanValidator.new
  end

end

class Hash
  def validate(&block)
    JSONValidate.validate(self, &block)
  end
end

class Array
  def validate(&block)
    JSONValidate.validate(self, &block)
  end
end

