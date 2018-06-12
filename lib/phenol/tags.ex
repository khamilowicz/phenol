defmodule Phenol.Tags do
  import NimbleParsec

  tag_name = ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)
  quoted_content = ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)

  not_tag_less_than = string("<") |> concat(ascii_char([{:not, ?/}, {:not, ?a..?z}]))

  not_tag_element =
    ascii_string([{:not, ?<}], min: 1)
    |> concat(optional(not_tag_less_than |> replace("&lt")))
    |> concat(optional(ascii_string([{:not, ?<}], min: 1)))
    |> reduce({Enum, :join, []})

  single_quoted_string =
    string("'")
    |> concat(optional(ascii_string([{:not, ?'}], min: 1)))
    |> concat(string("'"))

  double_quoted_string =
    string("\"")
    |> concat(optional(ascii_string([{:not, ?"}], min: 1)))
    |> concat(string("\""))

  quoted_string =
    choice([single_quoted_string, double_quoted_string])
    |> reduce({Enum, :join, []})

  tag_attr =
    optional(ignore(string(" ")))
    |> concat(tag_name)
    |> concat(ignore(string("=")))
    |> concat(quoted_string)
    |> wrap

  tag_content =
    tag_name
    |> optional(ignore(repeat(string(" "))))
    |> concat(wrap(repeat(tag_attr)))
    |> optional(ignore(repeat(string(" "))))

  defparsec(
    :single_tag,
    ignore(string("<"))
    |> concat(tag_content)
    |> ignore(string("/>"))
  )

  defparsec(
    :opening_tag,
    ignore(string("<"))
    |> concat(tag_content)
    |> ignore(string(">"))
  )

  defparsec(
    :closing_tag,
    ignore(string("</"))
    |> concat(tag_name)
    |> ignore(string(">"))
  )

  inner_tag_content =
    choice([
      not_tag_element,
      wrap(parsec(:single_tag)),
      wrap(parsec(:content_tag)),
    ])

  defparsec(
    :content_tag,
    parsec(:opening_tag)
    |> concat(wrap(repeat(inner_tag_content)))
    |> ignore(parsec(:closing_tag)),
    inline: true
  )

end
