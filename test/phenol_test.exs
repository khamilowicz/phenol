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

  defmodule NoStyleOrBody do
    use Phenol,
      blacklist: [
        tags: ["body"],
        attributes: ["style"]
      ]
  end

  describe "Phenol.strip_tags/1" do
    test "keeps tags and attributes we specify" do
      assert to_string(NoStyleOrBody.html!(@html)) |> String.replace(~r/\s\s/, "") == ~s{<html> <head> <title>Title</title> </head><ul> <li> <a href="http://example.com">A link!</a> </li> </ul></html>}
    end
  end
end
