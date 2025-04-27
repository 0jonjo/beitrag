require 'benchmark'
require 'json'
require 'set'
require 'open3'

# Configuration
API_URL = "http://localhost:3000/api/v1"
USER_COUNT = 100
IP_COUNT = 50
POSTS_COUNT = 4000
RATINGS_PERCENTAGE = 75

puts "Starting data generation at #{Time.now}"

# Generate user logins
puts "Generating user logins at #{Time.now}"
logins = Array.new(USER_COUNT) { |i| "user#{i + 1}" }

# Generate IP addresses
puts "Generating IP addresses at #{Time.now}"
ips = Array.new(IP_COUNT) { |i| "192.168.1.#{i + 1}" }

# Define curl helper method
def curl_post(endpoint, data)
  curl_cmd = %Q(curl -s -X POST "#{API_URL}/#{endpoint}" -H "Content-Type: application/json" -d '#{data.to_json}')
  stdout, stderr, status = Open3.capture3(curl_cmd)

  if !status.success?
    puts "Error executing curl command: #{stderr}"
    return nil
  end

  begin
    JSON.parse(stdout)
  rescue JSON::ParserError
    puts "Failed to parse response: #{stdout}"
    nil
  end
end

# Create posts and collect their IDs
puts "Creating #{POSTS_COUNT} posts at #{Time.now}"
post_ids = []

Benchmark.bm do |bm|
  bm.report("Creating posts") do
    POSTS_COUNT.times do |i|
      login = logins.sample
      ip = ips.sample

      post_data = {
        post: {
          title: "Post #{i + 1}",
          body: "This is the body of post #{i + 1}",
          login: login,
          ip: ip
        }
      }

      response = curl_post('posts', post_data)

      if response && response['post'] && response['post']['id']
        post_ids << response['post']['id']
      else
        puts "Failed to create post #{i + 1}"
      end

      puts "Created #{i + 1} posts at #{Time.now}" if (i + 1) % 1000 == 0
    end
  end
end

# Store post IDs for future use (in case the process needs to be restarted)
File.write('post_ids.txt', post_ids.join("\n"))

puts "All posts created successfully at #{Time.now}"
puts "Post IDs stored in post_ids.txt"

# Create ratings
ratings_count = (POSTS_COUNT * RATINGS_PERCENTAGE / 100).to_i
puts "Creating approximately #{ratings_count} ratings at #{Time.now}"

# Store which users have rated which posts to avoid duplicates
rated_posts = {}

Benchmark.bm do |bm|
  bm.report("Creating ratings") do
    ratings_count.times do |i|
      post_id = post_ids.sample
      user_id = nil

      # Find a user who hasn't rated this post yet
      loop do
        user_id = rand(USER_COUNT) + 1
        rated_posts[post_id] ||= Set.new

        # Only proceed if this user hasn't rated this post
        break unless rated_posts[post_id].include?(user_id)
      end

      rated_posts[post_id].add(user_id)
      rating_value = rand(1..5)

      rating_data = {
        rating: {
          post_id: post_id,
          user_id: user_id,
          value: rating_value
        }
      }

      curl_post('ratings', rating_data)

      puts "Created #{i + 1} ratings at #{Time.now}" if (i + 1) % 1000 == 0
    end
  end
end

puts "Data generation completed at #{Time.now}"
puts "Generated:"
puts "- #{USER_COUNT} users"
puts "- #{POSTS_COUNT} posts"
puts "- Using #{IP_COUNT} unique IP addresses"
puts "- Approximately #{ratings_count} ratings"
