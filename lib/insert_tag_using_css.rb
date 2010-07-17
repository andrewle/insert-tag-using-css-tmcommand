#!/usr/bin/env ruby

class InsertTagUsingCss
  TOKENS = /\.|#|\[|\]|=/
  SINGLE_TAG = /^(?:img|meta|link|input|base|area|col|frame|param|br|hr)$/i
  
  def initialize
    @attrs = { :class => [], :id => [], :named => {} }
    @current_named_attr = false
  end
  
  def execute(line)
    init_unparsed_tag(line)
    parse_tag
    insert_processed_tag
  end

  def init_unparsed_tag(s)
    @raw  = s.rstrip
    @unparsed_tag = s.strip.reverse[/^(.*?)(\s|$)/, 1].reverse
  end

  def parse_tag
    return if @unparsed_tag.empty?
    @tag = @unparsed_tag[/^(.*?)(#{TOKENS}|$)/, 1]
    unparsed_attrs = @unparsed_tag[@tag.length, @unparsed_tag.length]
    return if unparsed_attrs.empty?

    # valid types are :class and :id
    type, name = :class, ''
    unparsed_attrs.scan(/./).each_with_index do |char, i|
      eol = (i == unparsed_attrs.length - 1)
      if char.match(TOKENS)
        update_attrs(type, name)
        name = ''
        
        type = case char
               when /\./
                 :class
               when /#/
                 :id
               when /\[/
                 :named
               when /\]/
                 false
               when /\=/
                 type == :named ? :named_value : false
               end
        next
      else
        name += char
        update_attrs(type, name) if eol
      end
    end
  end
  
  def update_attrs(type, value)
    return if value.empty?
    case type
    when :class
      @attrs[:class] << value
    when :id
      @attrs[:id] << value
    when :named
      @attrs[:named][value] = ""
      @current_named_attr = value
    when :named_value
      return if !@current_named_attr or @current_named_attr.empty?
      return if !@attrs[:named].has_key?(@current_named_attr)
      @attrs[:named][@current_named_attr] = value
      @current_named_attr = false
    end
  end
  
  def insert_processed_tag
    line_stub + generate_tag
  end
  
  def line_stub
    tag_start = @raw.length - @unparsed_tag.length - 1
    tag_start == -1 ? '' : @raw[0..tag_start]
  end

  def generate_tag
    out = case @tag
          when SINGLE_TAG
            %Q{<#{@tag} #{named_attr} #{id_attr} #{class_attr} />}
          else
            %Q{<#{@tag} #{named_attr} #{id_attr} #{class_attr}>$1</#{@tag}>}
          end
    out.gsub(/(\s)\s*/, '\1').gsub(/\s+(>)/, '\1')
  end
  
  def named_attr
    return if @attrs[:named].empty?
    @attrs[:named].map { |k, v| %Q{#{k}="#{v}"} }.join(' ')
  end

  def id_attr
    %Q{id="#{@attrs[:id].join('-')}"} unless @attrs[:id].nil? or @attrs[:id].empty?
  end

  def class_attr
    %Q{class="#{@attrs[:class].join(' ')}"} unless @attrs[:class].nil? or @attrs[:class].empty?
  end
end

print InsertTagUsingCss.new.execute(STDIN.read)