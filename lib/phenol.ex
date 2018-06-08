defmodule Phenol do
  @moduledoc """
  Phenol is superfast html sanitizer
  """

  defmacro __using__(opts) do
    blacklist_tags = opts[:blacklist][:tags]
    blacklist_attrs = opts[:blacklist][:attributes]

    quote do
      def html!(html, opts \\ []) do
        case html(html, opts) do
          {:ok, res} -> res
        end
      end

      def html(html, opts \\ []) do
        with {:ok, content_tag, _, _, _, _} <- Phenol.Tags.content_tag(html),
             io_list when is_list(io_list) <- remove_tags(content_tag) do
          {:ok, io_list}
        end
      end

      defp remove_tags(string) when is_bitstring(string), do: string

      defp remove_tags([name, attrs, content]) when name in unquote(blacklist_tags) do
        Enum.map(content, &remove_tags/1)
      end

      defp remove_tags([name, [], content]) do
        ["<", name, ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_tags([name, attrs, content]) do
        ["<", name, remove_attrs(attrs), ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_attrs([]), do: []

      defp remove_attrs([[attr, value] | attrs]) when attr in unquote(blacklist_attrs) do
        remove_attrs(attrs)
      end

      defp remove_attrs([[attr, value] | attrs]) do
        [" ", attr, "=", value, remove_attrs(attrs)]
      end
    end
  end
end
