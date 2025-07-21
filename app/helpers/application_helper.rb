module ApplicationHelper
  def human_list(array)
    if array.empty?
      ""
    elsif array.length == 1
      array.first.to_s
    elsif array.length == 2
      "#{array[0]} en #{array[1]}"
    else
      "#{array[0...-1].join(", ")} en #{array[-1]}"
    end
  end
end
