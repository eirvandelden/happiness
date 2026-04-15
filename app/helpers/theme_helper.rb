module ThemeHelper
  def theme_attributes
    return {} unless Current.user

    # Only set data-theme when user has explicitly chosen non-system
    # MVPA.css handles system preference via prefers-color-scheme
    case Current.user.color_scheme
    when "light"
      { "data-theme": Current.user.light_theme }
    when "dark"
      { "data-theme": Current.user.dark_theme }
    else
      # System preference - let CSS handle it, no data-theme needed
      {}
    end
  end
end
