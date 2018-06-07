defmodule PhenolTest do
  use ExUnit.Case
  doctest Phenol

  @html """
  <html>
    <head>
      <title>Title</title>
    </head>
    <body>
      <ul>
        <li>
          <a href="http://example.com" style="background-color:red;">A link!</a>
        </li>
      </ul>
    </body>
  </html>
  """

  @tag :skip
  describe "Phenol.strip_tags/1" do
    test "removes all tags from html" do
      assert Phenol.strip_tags(@html) == """
      Title

      A link!
      """
    end
  end
end
