# lib/date_formatter.rb
require "date"

module DateFormatter
  def self.format_published_date_text(date_string)
    return nil unless date_string.present?

    normalized = date_string.strip.downcase

    # Localized month name translations (short + long)
    translations = {
      "jan." => "Jan", "feb." => "Feb", "mar." => "Mar", "apr." => "Apr",
      "maa." => "May", "mei" => "May", "jun." => "Jun", "jul." => "Jul",
      "aug." => "Aug", "sep." => "Sep", "okt." => "Oct", "nov." => "Nov", "dec." => "Dec",
      "januari" => "January", "februari" => "February", "maart" => "March",
      "april" => "April", "juni" => "June", "juli" => "July",
      "augustus" => "August", "september" => "September", "oktober" => "October",
      "november" => "November", "december" => "December"
    }

    translations.each do |local, eng|
      normalized.gsub!(local, eng)
    end

    known_formats = ["%d %B %Y", "%d %b %Y", "%d/%m/%Y"]

    known_formats.each do |format|
      begin
        return Date.strptime(normalized, format).strftime("%Y-%m-%d")
      rescue ArgumentError
        next
      end
    end

    nil
  rescue => error
    puts "Failed to parse date '#{date_string}': #{error}"
    nil
  end
end
