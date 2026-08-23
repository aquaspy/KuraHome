require "test_helper"

class IconFetchTest < ActiveSupport::TestCase
  test "rejects local and non-http urls" do
    assert_nil IconFetch.call("javascript:alert(1)")
    assert_nil IconFetch.call("http://127.0.0.1/secret")
    assert_nil IconFetch.call("http://localhost/secret")
    assert_nil IconFetch.call("http://192.168.0.1/x")
  end
end
