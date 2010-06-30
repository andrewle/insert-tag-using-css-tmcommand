#!/usr/bin/env ruby

class InsertTagUsingCss
  TOKENS = /\.|#/
  
  def initialize
    @attrs = { :class => [], :id => [] }
  end
  
  def execute
    get_unparsed_tag(STDIN.read)
    parse_tag
    print insert_into_line
  end

  def get_unparsed_tag(s)
    @raw  = s.rstrip
    @line = s.strip.reverse[/^(.*?)(\s|$)/, 1].reverse
  end

  def parse_tag
    return if @line.empty?
    @tag = @line[/^(.*?)(#{TOKENS}|$)/, 1]
    unparsed_attrs = @line[@tag.length, @line.length]

    return if unparsed_attrs.empty?

    # valid types are :class and :id
    type, name = :class, ''
    unparsed_attrs.scan(/./).each_with_index do |char, i|
      eol = (i == unparsed_attrs.length - 1)
      if char.match(TOKENS) or eol
        name += char if eol

        @attrs[type] << name unless name.empty?

        type = char.match(/\./) ? :class : :id unless eol
        name = ''
      else
        name += char
      end
    end
  end
  
  def insert_into_line
    line_stub + generate_tag
  end
  
  def line_stub
    tag_start = @raw.length - @line.length - 1
    tag_start == -1 ? '' : @raw[0..tag_start]
  end

  def generate_tag
    %Q{<#{@tag} #{id_attr} #{class_attr}></#{@tag}>}.gsub(/(\s)\s/, '\1').gsub(/\s(>)/, '\1')
  end

  def id_attr
    %Q{id="#{@attrs[:id].join('-')}"} unless @attrs[:id].nil? or @attrs[:id].empty?
  end

  def class_attr
    %Q{class="#{@attrs[:class].join(' ')}"} unless @attrs[:class].nil? or @attrs[:class].empty?
  end
end

InsertTagUsingCss.new.execute