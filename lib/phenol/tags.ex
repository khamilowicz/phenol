defmodule Phenol.Tags do
  import NimbleParsec

  tag_name = ascii_string([?a..?z, ?A..?Z], min: 1)
  quoted_content = ascii_string([?a..?z, ?A..?Z], min: 1)

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
    ignore(string(" "))
    |> concat(tag_name)
    |> concat(ignore(string("=")))
    |> concat(quoted_string)
    |> wrap

  tag_content =
    tag_name
    |> concat(wrap(repeat(tag_attr)))

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

  not_tag_element =
    ascii_string([{:not, ?<}, {:not, ?>}], min: 1)

  inner_tag_content =
    choice([not_tag_element, parsec(:content_tag), not_tag_element])

  defparsec(
    :content_tag,
    parsec(:opening_tag)
    |> concat(wrap(repeat(inner_tag_content)))
    |> ignore(parsec(:closing_tag))
  )
end
