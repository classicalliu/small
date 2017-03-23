require 'component_view'

class Component
  include ComponentView

  attr_reader :options, :block, :template_path, :attributes, :locals, :block_content, :controller

  def initialize options = {}, controller = nil, &block
    @controller = controller
    @options = options
    @block_content = block_given? ? yield : ""
    @template_path = options.delete(:template_path) || default_path
    @attributes = options.delete(:attributes)
    @locals = OpenStruct.new(options.delete(:locals))
  end

  def render
    view.render partial: self.template_path, locals: { component: self }
  end

  def tag_name
    @tag_name ||= class_name_without_modules.underscore.tr '_', '-'
  end

  def component_name
    class_name_without_modules.underscore
  end

  private

  def default_path
    "components/#{component_name}"
  end

  def class_name_without_modules
    self.class.name.demodulize
  end
end
