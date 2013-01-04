require 'strscan'

module PgHstore
  SINGLE_QUOTE = "'"
  DOUBLE_QUOTE = '"'

  extend self
  
  def parse(string)
    hash = {}

    # remove single quotes around literal if necessary
    string = string[1..-2] if string[0] == SINGLE_QUOTE and string[-1] == SINGLE_QUOTE

    scanner = StringScanner.new(string)
    while !scanner.eos?
      k = parse_quotable_string(scanner)
      skip_key_value_delimiter(scanner)
      v = parse_quotable_string(scanner)
      skip_pair_delimiter(scanner)
      # controversial...
      # to_sym, or what?
      hash[k.to_sym] = v
    end
    
    hash
  end

  # set for_parameter = true if you're using the output for a bind variable
  def dump(hash, for_parameter = false)
    string = hash.map do |k, v|
      if v.nil?
        # represent nil as NULL without quotes
        v = "NULL"
      else
        v = double_quote_escape v
        unless for_parameter
          v = single_quote_escape v
        end
        # otherwise, write a double-quoted string with backslash escapes for quotes
        v = DOUBLE_QUOTE + v + DOUBLE_QUOTE
      end
      k = double_quote_escape k
      unless for_parameter
        k = single_quote_escape k
      end
      k = DOUBLE_QUOTE + k + DOUBLE_QUOTE

      # TODO: throw an error if there is a NULL key
      [k, v].join ' => '
    end.join(", ")
    if for_parameter
      string
    else
      SINGLE_QUOTE + string + SINGLE_QUOTE
    end
  end

  private
  
  def quoted_string(scanner)
    key = scanner.scan(/(\\"|[^"])*/)
    key = key.gsub(/\\(.)/, '\1')
    scanner.skip(/"/)
    key
  end
  
  def parse_quotable_string(scanner)
    if scanner.scan(/"/)
      value = quoted_string(scanner)
    else
      value = scanner.scan(/\w+/)
      value = nil if value == "NULL"
      # TODO: values but not keys may be NULL
    end
  end

  def skip_key_value_delimiter(scanner)
    scanner.skip(/\s*=>\s*/) 
  end

  def skip_pair_delimiter(scanner)
    scanner.skip(/,\s*/)
  end

  def double_quote_escape(str)
    str.to_s.gsub DOUBLE_QUOTE, '\"'
  end

  def single_quote_escape(str)
    str.to_s.gsub(/\\(?!")/) {'\\\\'}.gsub(SINGLE_QUOTE, "''")
  end

end

