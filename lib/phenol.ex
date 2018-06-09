defmodule Phenol do
  @moduledoc """
  Phenol is superfast html sanitizer
  """

  defmacro __using__(opts) do
    whitelist = opts[:whitelist]
    blacklist = opts[:blacklist]

    list = opts[:whitelist] || opts[:blacklist]

    unless is_nil(whitelist) || is_nil(blacklist) do
      raise "either 'whitelist' or 'blacklist' param is allowed, not both"
    end

    if is_nil(list) do
      raise "either 'whitelist' or 'blacklist' param is required"
    end

    tag_list = list[:tags]
    attributes_list = list[:attributes]

    if Keyword.has_key?(opts, :whitelist) do
      Phenol.whitelist(tag_list, attributes_list)
    else
      Phenol.blacklist(tag_list, attributes_list)
    end
  end

  def whitelist(whitelist_tags, whitelist_attrs) do
    quote location: :keep do
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

      defp remove_tags([name, [], content]) when name in unquote(whitelist_tags) do
        ["<", name, ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_tags([name, attrs, content]) when name in unquote(whitelist_tags) do
        ["<", name, remove_attrs(attrs), ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_tags([_, _, content]) do
        Enum.map(content, &remove_tags/1)
      end

      defp remove_tags([name, []]) when name in unquote(whitelist_tags) do
        ["<", name, "/>"]
      end

      defp remove_tags([name, attrs]) when name in unquote(whitelist_tags) do
        ["<", name, remove_attrs(attrs), "/>"]
      end

      defp remove_tags([_, _]) do
        []
      end

      defp remove_attrs([]), do: []

      defp remove_attrs([[attr, value] | attrs]) when attr in unquote(whitelist_attrs) do
        [" ", attr, "=", value, remove_attrs(attrs)]
      end

      defp remove_attrs([[attr, value] | attrs]) do
        remove_attrs(attrs)
      end
    end
  end

  def blacklist(blacklist_tags, blacklist_attrs) do
    quote location: :keep do
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

      defp remove_tags([name, _, content]) when name in unquote(blacklist_tags) do
        Enum.map(content, &remove_tags/1)
      end

      defp remove_tags([name, [], content]) do
        ["<", name, ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_tags([name, attrs, content]) do
        ["<", name, remove_attrs(attrs), ">", Enum.map(content, &remove_tags/1), "</", name, ">"]
      end

      defp remove_tags([name, _]) when name in unquote(blacklist_tags) do
        []
      end

      defp remove_tags([name, []]) when name in unquote(blacklist_tags) do
        ["<", name, "/>"]
      end

      defp remove_tags([name, attrs]) do
        ["<", name, remove_attrs(attrs), "/>"]
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
