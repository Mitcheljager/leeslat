module ApplicationHelper
  # Create a string like "Naam, naam en naam". Renders html in order to render links
  def human_list(array)
    return "" if array.empty?

    if array.length == 1
      array.first.to_s.html_safe
    elsif array.length == 2
      "#{array[0]} en #{array[1]}".html_safe
    else
      "#{array[0...-1].join(", ")} en #{array[-1]}".html_safe
    end
  end

  # Turn an array of records into a human readable list mentioned above
  # Uses the "name" property by default
  def linked_human_list(records, key = :name)
    links = records.map do |record|
      text = record.send(key)
      path = polymorphic_path(record)

      link_to(text, path)
    end

    human_list(links)
  end
end
