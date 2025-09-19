module ApplicationHelper
  def render_markdown(text)
    return "".html_safe if text.blank?

    require "commonmarker"
    Commonmarker.to_html(text, options: { render: { unsafe: false } }).html_safe
  end

  def epic_progress_percentage(epic)
    total = epic.stories_count.to_i
    return 0 if total.zero?

    ((epic.accepted_count.to_f / total) * 100).round
  end

  def epic_progress_text(epic)
    "#{epic.accepted_count}/#{epic.stories_count}"
  end
end
