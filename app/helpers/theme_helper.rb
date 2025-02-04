module ThemeHelper
  def current_theme
    current_user&.dark_mode? ? 'dark' : 'light'
  end
end
