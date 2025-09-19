module ApplicationHelper
  def render_markdown(text)
    return "".html_safe if text.blank?

    require "commonmarker"
    Commonmarker.to_html(text, options: { render: { unsafe: false } }).html_safe
  end
end
