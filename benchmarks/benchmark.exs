{:ok, html} = File.read("./benchmarks/sample.html")

Benchee.run(
  %{
    "html_sanitize_ex strip_tags" => fn ->
      HtmlSanitizeEx.strip_tags(html)
    end,
    "phenol strip_tags" => fn ->
      Phenol.ScrubTags.html!(html)
    end
  },
  time: 10,
  memory_time: 2
)
