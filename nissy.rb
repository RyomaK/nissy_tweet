# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'clockwork'

CK = ENV["T_CK"]
CS = ENV["T_CS"]
AT = ENV["T_AT"]
ATC = ENV["T_ATC"]


class Tweet 
	def initialize(a,b,c,d)
		@consumer_key        = ""
		@consumer_secret     = ""
		@access_token        = ""
		@access_token_secret = ""
		@client = Twitter::REST::Client.new(
			consumer_key:        a,
			consumer_secret:     b,
			access_token:        c,
			access_token_secret: d
			)
	end

	def setData(n,k)
		doc_nissy = Nokogiri::HTML(open('http://avex.jp/nissy/news/'))
		doc_aaa = Nokogiri::HTML(open('http://avex.jp/aaa/news/'))
		@txt = ""
		if k == "nissy" then
			time = doc_nissy.xpath('//time')
			info = doc_nissy.xpath('//dd')

			
			@txt += time[n].inner_text
			@txt += "\n"
			@txt += info[n].inner_text
			@txt += "http://avex.jp/nissy/news/#{info[n].css('a')[0][:href].gsub(/.\//,"")} #Nissy #NissyEntertainment"
			ram = Rand.new()
			if @txt.length <= 140 then

			elsif @txt.length >140 then
				@txt.slice(140,@txt.length-140)
			end

		elsif k =="AAA" then
			year = doc_aaa.xpath('//dt/span')
			day = doc_aaa.xpath('//dt/time')
			info = doc_aaa.xpath('//dd')

			@txt += "#{year[n].inner_text}.#{day[n].inner_text.gsub("-",".")}"
			@txt += "\n"
			@txt += info[n].inner_text
			@txt += "\n http://avex.jp/aaa/news/#{info[n].css('a')[0][:href]} ##{k}"
			if @txt.length <= 140 then

			elsif @txt.length >140 then
				@txt.slice(140,@txt.length-140)
			end
		end
	end

	def getClient
		@client
	end

	def getTxt
		@txt
	end

	def refollow(client)
		follower_ids = []
		client.follower_ids('Nissy_inform').each do |id|
			follower_ids.push(id)
		end

		friend_ids = []
		client.friend_ids('Nissy_inform').each do |id|
			friend_ids.push(id)
		end
		client.follow(follower_ids - friend_ids)
	end

	def unfollow(client)
		follower_ids = []
		client.follower_ids('Nissy_inform').each do |id|
			follower_ids.push(id)
		end

		friend_ids = []
		client.friend_ids('Nissy_inform').each do |id|
			friend_ids.push(id)
		end
		client.unfollow(friend_ids - follower_ids)
	end

	def favoriteTweet(client)
		results = client.search("#Nissy", :count => 30, :result_type => "recent")
		results.attrs[:statuses].each do |tweet|
			id = tweet[:id].to_s
			client.favorite(id)
		end
		results = client.search("#AAA", :count => 30, :result_type => "recent")
		results.attrs[:statuses].each do |tweet|
			id = tweet[:id].to_s
			client.favorite(id)
		end
		results = client.search("#いいねした人全員フォローする", :count => 30, :result_type => "recent")
		results.attrs[:statuses].each do |tweet|
			id = tweet[:id].to_s
			client.favorite(id)
		end
	end


end

class Rand
	def initialize()
		@Rand  = rand(1..10)
	end
	def getRand
		@Rand
	end
end





include Clockwork
count = 0
every(10.minutes, 'nissy') do
	r = Rand.new()
	t = Tweet.new(CK,CS,AT,ATC)
	if count == 0 then	
		puts 'unfollow'
		t.unfollow(t.getClient)
	end
	count +=1

	t.favoriteTweet(t.getClient)
	t.refollow(t.getClient)

	t.setData(r.getRand,"nissy")
	puts t.getTxt
	t.getClient.update(t.getTxt)

	sleep(7200)

	t.setData(r.getRand,"AAA")
	puts t.getTxt
	t.getClient.update(t.getTxt)

	t.followUser(t.getClient)
	sleep(7200)

	t.setData(0,"nissy")
	puts t.getTxt
	t.getClient.update_with_media(t.getTxt,open("./img/#{r.getRand}.jpeg"))
	t.refollow(t.getClient)

	sleep(7200)

	t.setData(0,"AAA")
	puts t.getTxt
	t.getClient.update_with_media(t.getTxt,open("./img/#{r.getRand}.jpeg"))

	sleep(7200)

	puts count
end
