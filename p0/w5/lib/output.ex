defmodule Output do
  def start do
    ScrapeQuotes.scrape_to_http()
    ScrapeQuotes.scrape_to_quotes()
    ScrapeQuotes.scrape_to_json()
  end
end
