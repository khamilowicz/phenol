defmodule Phenol do
  @moduledoc """
  Phenol is superfast html sanitizer
  """

  @doc """
  Strips all tags from html
  """
  def strip_tags(text) do
    Phenol.StripTags.call(text)
  end
end
