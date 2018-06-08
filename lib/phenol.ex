defmodule Phenol do
  @moduledoc """
  Phenol is superfast html sanitizer
  """

  @doc """
  Strips all tags from html
  """
  def strip_tags!(html, opts \\ []) do
    case strip_tags(html, opts) do
      {:ok, res} -> res
    end
  end
  def strip_tags(html, opts \\ []) do
    with {:ok, content_tag, _, _, _, _} <- Phenol.Tags.content_tag(html), 
         io_list when is_list(io_list) <- remove_tags(content_tag) do
      {:ok, io_list}
    end
  end

  defp remove_tags(string) when is_bitstring(string), do: string
  defp remove_tags([name, attrs, content]) do
    remove_from_content(content)
  end

  defp remove_from_content(content_list) do
    Enum.map(content_list, &remove_tags/1)
  end
end
