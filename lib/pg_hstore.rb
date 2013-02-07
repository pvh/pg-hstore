module PgHstore
  SINGLE_QUOTE = "'"
  DOUBLE_QUOTE = '"'

  QUOTED_LITERAL = /"[^"\\]*(?:\\.[^"\\]*)*"/
  UNQUOTED_LITERAL = /[^\s=,][^\s=,\\]*(?:\\.[^\s=,\\]*|=[^,>])*/
  LITERAL = /(#{QUOTED_LITERAL}|#{UNQUOTED_LITERAL})/
  PAIR = /#{LITERAL}\s*=>\s*#{LITERAL}/
  NULL = /\ANULL\z/i
  # set symbolize_keys = false if you want string keys
  # thanks to https://github.com/engageis/activerecord-postgres-hstore for regexps!
  def PgHstore.load(hstore, symbolize_keys = true)
    hstore = unquote hstore, SINGLE_QUOTE
    hstore.scan(PAIR).inject({}) do |memo, (k, v)|
      k = unescape unquote(k, DOUBLE_QUOTE)
      k = k.to_sym if symbolize_keys
      v = (v =~ NULL) ? nil : unescape(unquote(v, DOUBLE_QUOTE))
      memo[k] = v
      memo
    end
  end

  # set for_parameter = true if you're using the output for a bind variable
  def PgHstore.dump(hash, for_parameter = false)
    memo = hash.map do |k, v|
      if v.nil?
        v = "NULL"
      else
        v = escape v
        unless for_parameter
          v = escape_single_quotes v
        end
        v = DOUBLE_QUOTE + v + DOUBLE_QUOTE
      end
      k = escape k
      unless for_parameter
        k = escape_single_quotes k
      end
      k = DOUBLE_QUOTE + k + DOUBLE_QUOTE
      [k, v].join ' => '
    end.join(', ')
    if for_parameter
      memo
    else
      SINGLE_QUOTE + memo + SINGLE_QUOTE
    end
  end

  class << self
    # deprecated; use PgHstore.load
    alias parse load
  end

  private

  def PgHstore.unquote(string, quote_char)
    if string.start_with? quote_char
      string[1..-2]
    else
      string
    end
  end

  ESCAPED_CHAR = /\\(.)/
  def PgHstore.unescape(literal)
    literal.gsub(ESCAPED_CHAR, '\1').gsub ESCAPED_SINGLE_QUOTE, SINGLE_QUOTE
  end
  
  NON_ESCAPE_SLASH = '\\'
  ESCAPED_SLASH = '\\\\'
  ESCAPED_DOUBLE_QUOTE = '\"'
  def PgHstore.escape(string)
    string.to_s.gsub(NON_ESCAPE_SLASH) {ESCAPED_SLASH}.gsub DOUBLE_QUOTE, ESCAPED_DOUBLE_QUOTE
  end

  ESCAPED_SINGLE_QUOTE = "''"
  def PgHstore.escape_single_quotes(literal)
    literal.to_s.gsub SINGLE_QUOTE, ESCAPED_SINGLE_QUOTE
  end

end

