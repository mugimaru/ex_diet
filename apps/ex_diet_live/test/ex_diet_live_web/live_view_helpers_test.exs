defmodule ExDietLiveWeb.LiveViewHelpersTest do
  use ExUnit.Case, async: true
  import ExDietLiveWeb.LiveViewHelpers

  describe ".get_patched_path/2" do
    test "returns changed path for given URI and params" do
      assert {:ok, "/foo?x=xx"} == get_patched_path("https://example.com/foo?q=foobar&x=xx", q: nil)
      assert {:unchanged, "/foo?q=foobar&x=xx"} == get_patched_path("https://example.com/foo?q=foobar&x=xx", x: "xx")
      assert {:unchanged, "/foo?q=foobar&x=xx"} == get_patched_path("https://example.com/foo?q=foobar&x=xx", [])
      assert {:ok, "/foo?q=foobar&z=zz"} == get_patched_path("https://example.com/foo?q=foobar&x=xx", x: "", z: "zz")
    end
  end
end
