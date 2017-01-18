#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'

Dir.glob("**/**/*.htm") do |file_name|
	# Read file
	data = File.open(file_name, "r:utf-8").read

	# Read file content
	document = Nokogiri::HTML(data)

	# Parsing file content
	document.at('div[class="chap"]').search('table[class="tablefloat"]').each do |row|
  	actual_data = row.search('td')

  	verse_number  = actual_data.search('span[class="reftop3"]').text
  	strong_number = actual_data.search('span[class="pos"]').text
  	greek_eng     = actual_data.search('span[class="translit"]').text
  	greek         = actual_data.search('span[class="greek"]').text
  	eng_word      = actual_data.search('span[class="eng"').text
  	word_type     = actual_data.search('span[class="strongsnt"]').text

  	puts unique_number
  	
	  #puts CSV.generate_line(cells)
	end
end