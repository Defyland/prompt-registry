# frozen_string_literal: true

module PromptRegistry
  PromptEntry = Struct.new(:id, :version, :summary, :path, :placeholders, keyword_init: true) do
    def label
      "#{id}@#{version}"
    end
  end
end
