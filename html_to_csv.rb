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

book_belongs_to = ARGV[0]

verse_data = {}
data = []
temp_data = []

header = "Book Name, Chapter, Verse, Strong Number, Greek Eng, Greek, Eng Word, Word Type"
file = "interlinear.csv"

CSV.open( file, 'w' ) do |head|
  head << header.split(',')
end

# Sorce file has different css class in nt and ot.
if book_belongs_to == "nt"
  table_data_calss         = 'table[class="tablefloat"]'
  verse_nbr_table_class    = 'span[class="reftop3"]'
  strong_number_span_class = 'span[class="pos"]'
  greek_eng_span_class     = 'span[class="translit"]'
  greek_span_class         = 'span[class="greek"]'
  eng_word_span_class      = 'span[class="eng"]'
  word_type_span_class     = 'span[class="strongsnt"]'
elsif book_belongs_to == "ot"
  table_data_calss         = 'table[class="tablefloatheb"]'
  verse_nbr_table_class    = 'span[class="refheb"]'
  strong_number_span_class = 'span[class="strongs"]'
  greek_eng_span_class     = 'span[class="translit"]'
  greek_span_class         = 'span[class="hebrew"]'
  eng_word_span_class      = 'span[class="eng"]'
  word_type_span_class     = 'span[class="strongsnt"]'
end

count = 0
Dir.glob("**/**/*.htm") do |file_name|
  data=[]
  ProcessingIcon.new.spin_it count += 1
  check_verse = "1"
	file_data = File.open(file_name, "r:utf-8").read # Read file
	document = Nokogiri::HTML(file_data) # Read file content
  book_name = File.dirname(file_name).split('/').last
  
  extn = File.extname file_name
  chapter_name = File.basename file_name, extn

	# Parsing file content
	document.at('div[class="chap"]').search(table_data_calss).each do |row|
  	actual_data = row.search('td')

    # Require data from source
  	verse_nbr     = actual_data.search(verse_nbr_table_class).text
  	strng_nbr     = actual_data.search(strong_number_span_class).text
  	grk_eng       = actual_data.search(greek_eng_span_class).text
  	grk           = actual_data.search(greek_span_class).text
  	eg_wrd        = actual_data.search(eng_word_span_class).text
  	wrd_typ       = actual_data.search(word_type_span_class).text

    # Final and clean data from source
    verse_number  = verse_nbr.gsub(/[[:space:]]/, '')
    
    str_nbr       = strng_nbr.gsub(/\[.*\]/, "")
    strong_number = str_nbr.gsub(/[[:space:]]/, '')

    greek_eng     = grk_eng #.gsub(/[[:space:]]/, '')
    greek         = grk #.gsub(/[[:space:]]/, '')
    eng_word      = eg_wrd #.gsub(/[[:space:]]/, '')
    word_type     = wrd_typ #.gsub(/[[:space:]]/, '')

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
  if(data.size > 0)
      verse_data[check_verse] = data
      data = []
  end

  # puts verse_data

  CSV.open( file, 'a' ) do |writer|
    verse_data.each do |verse_number, linear_array|
      linear_array.each do |linear_data|
        puts "#############        greek          ############"
        puts linear_data["greek"]
        puts "###########         eng_word        ##############"
        puts linear_data["eng_word"]
        writer << [book_name, chapter_name, verse_number, linear_data["strong_number"], linear_data["greek_eng"], linear_data["greek"], linear_data["eng_word"], linear_data["word_type"] ]
      end
    end
    verse_data = {}
  end

end