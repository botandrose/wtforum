require "spec_helper"

describe WTForum do
  subject do
    test_wtforum
  end

  its(:base_uri) { should == URI("http://forums.complexityexplorer.org") }
  its(:base_api_uri) { should == URI("http://forums.complexityexplorer.org?apikey=pteGzAPZyr4") }
end

