require 'nokogiri'
require 'httparty'
require 'byebug'

def scraper
  url = 'https://rabota.ua/jobsearch/vacancy_list'
  unparsed_page = HTTParty.get(url)
  parsed_page = Nokogiri::HTML(unparsed_page)

  jobs = Array.new
  job_listings = parsed_page.css('div.card-body')

  page = 1
  jobs_per_page = job_listings.count
  total_pages = parsed_page.css('span#ctl00_content_ctl00_ltCount').text.split(' ')[1].gsub(/[[:space:]]/, '').to_i
  last_page = (total_pages.to_f / jobs_per_page).round

  while page <= last_page
    pagination_url = "https://rabota.ua/jobsearch/vacancy_list?pg=#{page}"
    puts pagination_url
    puts "Current page: #{page}"

    pagination_unparsed_page = HTTParty.get(pagination_url)
    pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
    pagination_job_listings = pagination_parsed_page.css('div.card-body')

    pagination_job_listings.each do |job_listing|
      job = {
        title: job_listing.css('p.card-title').text,
        company: job_listing.css('p.company-name').text,
        location: job_listing.css('span.location').text,
        description: job_listing.css('div.card-description').text,
        url: 'https://rabota.ua' + job_listing.css('a')[0].attributes['href'].value
      }
      jobs << job
      puts "Added #{job[:title]}"
    end
    page += 1
  end
  byebug
end

scraper