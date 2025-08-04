require "date"

module LogTime
  def self.log_end_time(start_time)
    end_time = DateTime.now
    total_seconds = ((end_time - start_time) * 24 * 60 * 60).to_f
    minutes = (total_seconds / 60).to_i
    seconds = (total_seconds % 60).round

    puts "\e[34m"
    puts "===================="
    puts "Run started at #{start_time}"
    puts "Run ended at #{end_time}"
    puts "Total time: #{minutes} minutes and #{seconds} seconds"
    puts "===================="
    puts "\e[0m"
  end
end
