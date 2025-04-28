require 'benchmark'
require 'json'
require 'set'
require 'parallel'

API_URL = "http://localhost:3000/api/v1"
USER_COUNT = 100
IP_COUNT = 50
POSTS_COUNT = 200000
RATINGS_PERCENTAGE = 75
PARALLEL_THREADS = 10

puts "Starting data generation at #{Time.now}"

puts "Generating user logins at #{Time.now}"
logins = Array.new(USER_COUNT) { |i| "user#{i + 1}" }

puts "Generating IP addresses at #{Time.now}"
ips = Array.new(IP_COUNT) { |i| "192.168.1.#{i + 1}" }

def curl_post(endpoint, data)
  begin
    response = `curl -s -X POST "#{API_URL}/#{endpoint}" -H "Content-Type: application/json" -d '#{data.to_json}'`

    unless $?.success?
      puts "Error executing curl command"
      return nil
    end

    begin
      JSON.parse(response)
    rescue JSON::ParserError
      puts "Failed to parse response: #{response}"
      nil
    end
  rescue StandardError => e
    puts "Error: #{e.message}"
    nil
  end
end

puts "Creating #{POSTS_COUNT} posts at #{Time.now}"
post_ids = []
mutex = Mutex.new

post_data_array = []
POSTS_COUNT.times do |i|
  login = logins.sample
  ip = ips.sample

  post_data_array << {
    index: i + 1,
    data: {
      post: {
        title: "Post #{i + 1}",
        body: "This is the body of post #{i + 1}",
        login: login,
        ip: ip
      }
    }
  }
end

Benchmark.bm do |bm|
  bm.report("Creating posts in parallel") do
    Parallel.each_with_index(post_data_array, in_threads: PARALLEL_THREADS) do |post_item, idx|
      i = post_item[:index]
      post_data = post_item[:data]

      response = curl_post('posts', post_data)

      if response && response['post'] && response['post']['id']
        mutex.synchronize do
          post_ids << response['post']['id']

          if post_ids.size % 1000 == 0 || post_ids.size == POSTS_COUNT
            puts "Created #{post_ids.size} posts at #{Time.now}"
          end
        end
      else
        puts "Failed to create post #{i}"
      end
    end
  end
end

File.write('post_ids.txt', post_ids.join("\n"))

puts "All posts created successfully at #{Time.now}"
puts "Post IDs stored in post_ids.txt"

ratings_count = (POSTS_COUNT * RATINGS_PERCENTAGE / 100).to_i
puts "Creating #{ratings_count} ratings at #{Time.now}"

rated_posts = {}
rated_posts_mutex = Mutex.new

ratings_data_array = []
ratings_count.times do |i|
  ratings_data_array << { index: i + 1 }
end

Benchmark.bm do |bm|
  bm.report("Creating ratings in parallel") do
    Parallel.each(ratings_data_array, in_threads: PARALLEL_THREADS) do |rating_item|
      i = rating_item[:index]
      post_id = nil
      user_id = nil

      rated_posts_mutex.synchronize do
        loop do
          post_id = post_ids.sample
          user_id = rand(USER_COUNT) + 1

          rated_posts[post_id] ||= Set.new

          # Only proceed if this user hasn't rated this post
          break unless rated_posts[post_id].include?(user_id)
        end

        rated_posts[post_id].add(user_id)
      end

      rating_value = rand(1..5)

      rating_data = {
        rating: {
          post_id: post_id,
          user_id: user_id,
          value: rating_value
        }
      }

      curl_post('ratings', rating_data)

      if i % 1000 == 0 || i == ratings_count
        mutex.synchronize do
          puts "Created #{i} ratings at #{Time.now}"
        end
      end
    end
  end
end

puts "Data generation completed at #{Time.now}"
puts "Generated:"
puts "- #{USER_COUNT} users"
puts "- #{POSTS_COUNT} posts"
puts "- Using #{IP_COUNT} unique IP addresses"
puts "- Approximately #{ratings_count} ratings"
