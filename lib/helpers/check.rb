module RBKubeMQ
  module Check
    def is_class?(object, classes, name)
      return if classes.include?(object.class)
      raise RBKubeMQ::Error.new("#{name} should be #{classes.map(&:to_s).join(", ")}")
    end
  end
end
