require 'rubygems'
require 'hpricot'

class SafariPlist
  attr_reader :url,:access_time,:visit_count,:title
  
  def initialize(url="",acess_time="",visit_count="",title="")
    @url =url
    @access_time = (Time.utc(2001,"jan",1,0,0,0)+access_time.to_f).to_s
    @visit_count = visit_count
    @title = title
  end
  
  def self.get_history(file_name,plutil_path="plutil")
      result = ""
      @histories = []
     if !file_name.nil?
       result = `#{plutil_path} -i #{file_name}`
       doc = Hpricot.parse(result)  
       @histories = self.process_history(doc)
       puts "hello"
     else
        puts "Please enter file name"
        return -1
     end
     @histories 
  end
  
  def self.process_history(doc)
    safari_history = []
    doc.get_elements_by_tag_name("array").first.get_elements_by_tag_name("dict").each do |hp_doc|
      browsing_url = ""
      access_time = ""
      no_of_visit = ""
      title =""
      hp_doc.get_elements_by_tag_name("string").each do |value|
        string_value = value.innerText.match(/((\w+):\/\/(.+))/)
        if !string_value.nil?
          browsing_url = string_value[0]
        elsif !value.previous_node.nil? && !value.previous_node.previous_node.nil?   
          node_text= value.previous_node.previous_node.innerText 
          access_time = value.innerText if node_text == "lastVisitedDate"
          title = value.innerText if node_text == "title"    
        end
      end 
      hp_doc.get_elements_by_tag_name("integer").each do |visit_count|
        if !visit_count.previous_node.nil? && !visit_count.previous_node.previous_node.nil? && visit_count.previous_node.previous_node.innerText == "visitCount"
          no_of_visit = visit_count.innerText 
        end
      end
      safari_history << SafariPlist.new(browsing_url,access_time,no_of_visit,title)
    end
    safari_history
  end
end

