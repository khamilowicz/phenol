defmodule Phenol.TagTest do
  use ExUnit.Case

  @nested_html """
  <div style="background-color:red;margin-top:10px" class="pretty not-really">
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

    assert {:ok, ["div", [["style", "'lol'"]], ["content"]], _, _, _, _} =
             Phenol.Tags.content_tag("<div style='lol'>content</div>")

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

  @tag :skip
  test "actual file" do
    file = File.read!("./test/phenol/test_file.html")
    Phenol.Tags.content_tag(file) |> IO.inspect()
  end
end
