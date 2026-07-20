module ApplicationHelper
  # Marks the link as the current page via aria-current, instead of
  # link_to_unless_current's approach of dropping the link entirely.
  def nav_link_to(text, path)
    link_to text, path, aria: { current: ("page" if current_page?(path)) }
  end
end
