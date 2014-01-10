module ProtesteScaffold
  class Security

    def self.can?(path = nil)
      true
    end

    def self.partial_permission?(path = nil)
      true
    end

    def self.clean
      true
    end
  end
end