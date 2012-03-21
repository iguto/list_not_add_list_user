# -*- coding: utf-8 -*-

###
# unlisted_follow.rb
# 
# Twitterで、followしているが、listへ追加されていないユーザをリストアップする

require 'twitter'

###
# setting

# Auth Token
$token_path = 'option_cl'
$user_id = 'clc_igu'

# number of use API
$num_api = 0

###
# トークンの読出し
def load_token
  tokens = File.open($token_path,'r').readlines
  # p tokens.shift.chomp
  # p tokens.shift.chomp
  # p tokens.shift.chomp
  # p tokens.shift.chomp
  Twitter.configure do |config|
    config.consumer_key = tokens.shift.chomp
    config.consumer_secret = tokens.shift.chomp
    config.oauth_token = tokens.shift.chomp
    config.oauth_token_secret = tokens.shift.chomp
  end
end

def get_all_list_members(list)
  next_cursor = -1
  arr = []
  loop do 
    break  if next_cursor == 0
    data = Twitter.list_members(list,{:cursor => next_cursor})
    $num_api += 1
    next_cursor = data.next_cursor
    this_map =  data.users.map {|u| u.id }
    arr = arr + this_map
  end
  arr
end

###
# main

# トークンの設定
load_token

# 作成済みリストの取得

# mylists = Twitter.lists.lists.map do |list|
#   list['name']
# end
#     $num_api += 1
mylists = ['chck','around','spcamp-all']

# 全フォローの取得
all_friends = Twitter.friend_ids.ids
$num_api += 1
puts "all friends: #{all_friends.size}"

# リストでフォローしてる人をunlisted_friendsから除外していく
list_friends = mylists.map do |list|
  tmp = get_all_list_members(list)
  puts "in #{list} friends : #{tmp.size}"
  tmp
end
puts '='*20
unlisted_friends = all_friends - list_friends.flatten


count = 0
loop do
  if unlisted_friends == []
    break
  end
  part_unlisted_friends = unlisted_friends.shift(100)
  $num_api += 1
  final = Twitter.users(part_unlisted_friends).map do |u|
    "#{u.name} / #{u.screen_name}"
    count += 1
  end
  puts final
end

puts "="*20
puts "unlisted #{count} users found."
puts
puts "this script used #{$num_api}APIs"
