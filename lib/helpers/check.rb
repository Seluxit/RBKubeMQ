module RBKubeMQ
  module Check
    def is_class?(object, classes, name)
      return if classes.include?(object.class)
      raise RBKubeMQ::Error.new("#{name} should be #{classes.map(&:to_s).join(", ")}")
    end

    def is_in_list?(value, list, name)
      return if list.include?(value)
      raise RBKubeMQ::Error.new("#{name} should be #{list.join(", ")}")
    end
  end
end
