# frozen_string_literal: true

module Adapter
  class BaseAdapter
    def read
      raise StandardError.new, 'Adapter does not implement read()'
    end

    def write
      raise StandardError.new, 'Adapter does not implement write()'
    end
  end
end