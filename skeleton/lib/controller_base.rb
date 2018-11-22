require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @res = res
    @req = req
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'already built' if @already_built_response
    @res.status = 302
    @res["Location"] = url
    nil
    @already_built_response = @res["Location"]
    session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = 'text/html')
    raise 'already built' if @already_built_response
    @already_built_response = !@already_built_response 
    @res.write(content)
    @res['Content-Type'] = content_type
    session.store_session(@res)
    nil    
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir_path = File.dirname(__FILE__)
    template_path = File.join(
      dir_path, "..", "views", self.class.name.underscore, "#{template_name}.html.erb"
    )
  
    template_code = File.read(template_path)
  
    render_content(
      ERB.new(template_code).result(binding),
      "text/html"
    )
  end
  
  attr_accessor :already_built_response
  # 
  #  def prepare_render_or_redirect
  #    raise "double render error" if already_built_response?
  #    @already_built_response = true
  #    session.store_session(@res)
  # end
  # 
  # # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end
  

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

end

