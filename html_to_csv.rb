#!/usr/bin/env ruby

require 'nokogiri'
require 'csv'

class ProcessingIcon
  def spin_it(times)
    pinwheel = %w{| .. - \\}
    times.times do
      print "\b" + pinwheel.rotate!.first
      sleep(0.1)
    end
  end
end

verse_data = {}
data = []
temp_data = []

header = "Book Name, Chapter, Verse, Strong Number, Greek Eng, Greek, Eng Word, Word Type"
file = "interlinear.csv"

CSV.open( file, 'w' ) do |head|
  head << header.split(',')
end

count = 0
Dir.glob("**/**/*.htm") do |file_name|
  ProcessingIcon.new.spin_it count += 1
  check_verse = "1"
	file_data = File.open(file_name, "r:utf-8").read # Read file
	document = Nokogiri::HTML(file_data) # Read file content
  book_name = File.dirname(file_name).split('/').last
  
  extn = File.extname  file_name
  chapter_name = File.basename file_name, extn

	# Parsing file content
	document.at('div[class="chap"]').search('table[class="tablefloat"]').each do |row|
  	actual_data = row.search('td')

  	verse_nbr     = actual_data.search('span[class="reftop3"]').text
  	strong_number = actual_data.search('span[class="pos"]').text
  	greek_eng     = actual_data.search('span[class="translit"]').text
  	greek         = actual_data.search('span[class="greek"]').text
  	eng_word      = actual_data.search('span[class="eng"]').text
  	word_type     = actual_data.search('span[class="strongsnt"]').text
    verse_number  = verse_nbr.gsub(/[[:space:]]/, '')

    if(verse_number == check_verse or verse_number == "")
      if(temp_data.size > 0)
        data.push(temp_data[0])
        temp_data = []
      end
      data.push({"strong_number" => strong_number, "greek_eng" => greek_eng, "greek" => greek, "eng_word" => eng_word, "word_type" => word_type })
    else
      if ((verse_number != check_verse) and verse_number != "")
        temp_data.push({"strong_number" => strong_number, "greek_eng" => greek_eng, "greek" => greek, "eng_word" => eng_word, "word_type" => word_type })
      end
      verse_data[check_verse] = data
      data = []
      check_verse = verse_number
    end

	end

  CSV.open( file, 'a' ) do |writer|
    verse_data.each do |verse_number, linear_array|
      linear_array.each do |linear_data|
        writer << [book_name, chapter_name, verse_number, linear_data["strong_number"], linear_data["greek_eng"], linear_data["greek"], linear_data["eng_word"], linear_data["word_type"] ]
      end
    end
  end

end