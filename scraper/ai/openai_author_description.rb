require_relative "../../config/environment"
require "openai"

name = ARGV[0]

author = Author.find_by_name(name)
if author.blank?
  puts "Author #{name} was not found"
  return
end

client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"], log_errors: true)

puts "Generating description for #{author.name}..."

response = client.chat(parameters: {
  model: "gpt-4.1-mini",
  messages: [{
    role: "system",
    content: "You are a describer of authors. You will be given the name of an author. Your task is to provide a short and accurate description of that author. Accuracy is key. The description should be between 2 and 5 sentences. If not enough information is known about the author, you will provide no made up information. You will provide the text in Dutch. The tone should generally be positive, light, and informative. Only describe the author, not their books."
  }, {
    role: "user",
    content: "Please provide a short and accurate description of the author #{author.name} in Dutch."
  }],
  temperature: 0.7
})

message = response["choices"][0]["message"]["content"]

puts "Summary: #{message}"

author.update(description: message)
