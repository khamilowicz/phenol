defmodule Phenol.TagTest do
  use ExUnit.Case

  @nested_html """
  <div style="background-color:red;margin-top:10px" class="pretty not-really">
    <link src="/example.com" />
    <ul>
      <li>
        <a href="http://www.google.com">Link!</a>
        <a href="http://www.google.com">Link!</a>
      </li>
      <li>
        <a href="http://www.google.com">Link!</a>
        <a href="http://www.google.com">Link!</a>
      </li>
    </ul>
  </div>
  """

  test "Phenol.Tag parses tags" do
    assert {:ok, ["b", []], _, _, _, _} = Phenol.Tags.single_tag("<b/>")
    assert {:ok, ["div", []], _, _, _, _} = Phenol.Tags.opening_tag("<div>")
    assert {:ok, ["div"], _, _, _, _} = Phenol.Tags.closing_tag("</div>")

    assert {:ok, ["div", [], ["content"]], _, _, _, _} =
             Phenol.Tags.content_tag("<div>content</div>")

    assert {:ok, ["h1", [], ["content"]], _, _, _, _} =
             Phenol.Tags.content_tag("<h1>content</h1>")

    assert {:ok, ["div", [], [["h1", [], ["content"]]]], _, _, _, _} =
             Phenol.Tags.content_tag("<div><h1>content</h1></div>")

    assert {:ok, ["div", [["style", "'lol'"]], ["content"]], _, _, _, _} =
             Phenol.Tags.content_tag("<div style='lol'>content</div>")

    assert {:ok, ["div", [["style", "'lol'"]], [["b", []], " content"]], _, _, _, _} =
             Phenol.Tags.content_tag("<div style='lol'><b /> content</div>")

    assert {:ok, ["div", [["style", "'lol'"]], [["b", []], " &lt content "]], _, _, _, _} =
             Phenol.Tags.content_tag("<div style='lol'><b /> <3 content </div>")

    assert {:ok,
            [
              "div",
              [["style", "'lol'"], ["type", "\"input\""]],
              [" this is content "]
            ], _, _, _,
            _} =
             Phenol.Tags.content_tag("<div style='lol' type=\"input\"> this is content </div>")

    assert {:ok,
            [
              "div",
              [
                ["style", "\"background-color:red;margin-top:10px\""],
                ["class", "\"pretty not-really\""]
              ],
              [
                "\n  ",
                ["link", [["src", "\"/example.com\""]]],
                "\n  ",
                [
                  "ul",
                  [],
                  [
                    "\n    ",
                    [
                      "li",
                      [],
                      [
                        "\n      ",
                        [
                          "a",
                          [["href", "\"http://www.google.com\""]],
                          ["Link!"]
                        ],
                        "\n      ",
                        [
                          "a",
                          [["href", "\"http://www.google.com\""]],
                          ["Link!"]
                        ],
                        "\n    "
                      ]
                    ],
                    "\n    ",
                    [
                      "li",
                      [],
                      [
                        "\n      ",
                        [
                          "a",
                          [["href", "\"http://www.google.com\""]],
                          ["Link!"]
                        ],
                        "\n      ",
                        [
                          "a",
                          [["href", "\"http://www.google.com\""]],
                          ["Link!"]
                        ],
                        "\n    "
                      ]
                    ],
                    "\n  "
                  ]
                ],
                "\n"
              ]
            ], "\n", _, _, _} = Phenol.Tags.content_tag(@nested_html)
  end

  test "actual file" do
    file = File.read!("./test/phenol/test_file.html")
    assert {:ok, _, _, _, _} = Phenol.Tags.content_tag(file)
  end
end
