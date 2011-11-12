require './lib/hstore'

describe "hstores from hashes" do
  before do
    @h = HStore::dump :a => "b", :foo => "bar"
  end

  it "should translate into a sequel literal" do
    @h.should == '\'"a" => "b", "foo" => "bar"\''
  end
end

describe "creating hstores from strings" do
  before do
    @h = HStore::parse (
      "\"ip\"=>\"17.34.44.22\", \"service_available?\"=>\"false\"")
  end

  it "should set a value correctly" do
    @h[:service_available?].should == "false"
  end

  it "should store an empty string" do
    hstore = HStore::dump :nothing => ""
    hstore.should == '\'"nothing" => ""\''
  end

  it "should support single quotes in strings" do
    hstore = HStore::dump :journey => "don't stop believin'"
    hstore.should == %q{'"journey" => "don''t stop believin''"'}
  end

  it "should support double quotes in strings" do
    hstore = HStore::dump :journey => 'He said he was "ready"'
    hstore.should == %q{'"journey" => "He said he was \"ready\""'}
  end

  it "should escape \ garbage in strings" do
    hstore = HStore::dump :line_noise => %q[perl -p -e 's/\$\{([^}]+)\}/] #'
    hstore.should == %q['"line_noise" => "perl -p -e ''s/\\\\$\\\\{([^}]+)\\\\}/"']
  end

  it "should parse an empty string" do
    hstore = HStore.parse(
      "\"ip\"=>\"\", \"service_available?\"=>\"false\"")

    hstore[:ip].should == ""
    hstore[:ip].should_not == nil
  end

  it "should be able to parse its own output" do
    data = { :journey => 'He said he was ready' }
    hstore = HStore::dump data
    parsed = HStore::parse(hstore)
    parsed.should == data
  end

  it "should be able to parse hstore strings without ''" do
    data = { :journey => 'He said he was ready' }
    literal = HStore::dump data
    parsed = HStore.parse(literal[1..-2])
    parsed.should == data
  end

  it "should be stable over iteration" do
    dump = HStore::dump :journey => 'He said he was "ready"'
    parse = HStore::parse dump

    original = dump

    10.times do
      parsed = HStore::parse(dump)
      dump = HStore::dump(parsed)
      dump.should == original
    end
  end
end

