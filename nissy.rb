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
			@txt += "http://avex.jp/nissy/news/#{info[n].css('a')[0][:href].gsub(/.\//,"")} ##{k}"
			ram = Rand.new()
			if @txt.length <= 140 then
				
			elsif @txt.length >=140 then
				@txt.gsub(140..@txt.length,"")
			end

		elsif k =="AAA" then
			time = doc_aaa.xpath('//dt')
			info = doc_aaa.xpath('//dd')

			@txt += time[n].inner_text
			@txt += "\n"
			@txt += info[n].inner_text.gsub(/newUp.+/,"\n")
			@txt += " http://avex.jp/aaa/news/#{info[n].css('a')[0][:href]} ##{k}"
			ram = Rand.new()
			@txt += " " * ram.getRand
			if @txt.length <= 140 then
				
			elsif @txt.length >=140 then
				@txt.gsub(140..@txt.length,"")
			end
		end
	end

	def getClient
		@client
	end

	def getTxt
		@txt
	end

	end

	class Rand
		def initialize()
			@Rand  = rand(1..8)
		end
		def getRand
			@Rand
		end
	end





	include Clockwork
	every(10.minutes, 'nissy') do

		r = Rand.new()
		t = Tweet.new(CK,CS,AT,ATC)

		t.setData(r.getRand,"nissy")
		puts t.getTxt
		t.getClient.update(t.getTxt)

		sleep(6000)

		t.setData(r.getRand,"AAA")
		puts t.getTxt
		t.getClient.update(t.getTxt)

		sleep(6000)

		t.setData(0,"nissy")
		puts t.getTxt
		t.getClient.update(t.getTxt)

		sleep(6000)

		t.setData(0,"AAA")
		puts t.getTxt
		t.getClient.update(t.getTxt)

	end