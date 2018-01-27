#!/usr/bin/env ruby

require 'watir'
require 'nokogiri'
require 'headless'
require 'netrc'
require 'pp'

DEFAULT_SLEEP = 5

def login(browser)
  email, password = Netrc.read()['amazon.com']
  if(!email.nil?) && (!password.nil?)
    puts "Logging in as #{email}"
    browser.goto('https://www.amazon.com/clouddrive/')
    browser.a(target: '_self').click
    browser.text_field(id: 'ap_email').wait_until_present
    browser.text_field(id: 'ap_email').set email
    browser.text_field(id: 'ap_password').set password
    browser.input(type: 'submit').click
    browser.input(type: 'submit').wait_while_present
    puts 'Login success'
    return true
  else
    puts 'Unable to get amazon.com username or password from .netrc'
    return false
  end
end

def trash_count(browser)
  browser.goto('https://www.amazon.com/clouddrive/trash')
  sleep(DEFAULT_SLEEP)
  browser.li(class: 'count').wait_until_present
  nokogiri_document = Nokogiri::HTML(browser.html)
  count = nokogiri_document.css('#trash-page > section > header > div.breadcrumb-column > ul > li.count > span')[0].text.to_i
  puts "Trash count: #{count}"
  return count
end

def empty_trash(browser)
  browser.goto('https://www.amazon.com/clouddrive/trash')
  browser.button(class: 'select-all').wait_until_present
  puts "Got Trash page"
  sleep(DEFAULT_SLEEP)
  puts "Sorting by size"
  size_button = browser.button(css: 'span.detail.Size > button.sort')
  # $stderr.puts size_button.inspect
  size_button.click!
  sleep(DEFAULT_SLEEP)
  # browser.button(class: 'select-all', title: "Select").click
  print "Clicking 'Select' buttons, please wait..."
  # Watir.relaxed_locate = true
  # Watir.logger.level = :debug
  # Selenium::WebDriver.logger.level = :info
  browser.buttons(class: 'select-item', title: "Select").each do |select_button|
    # $stderr.puts select_button.inspect
    select_button.click!
    # browser.span(class: 'icon-spinner').wait_until_present
    # sleep(DEFAULT_SLEEP)
    begin
      browser.span(class: 'icon-spinner').wait_while_present
    rescue Watir::Wait::TimeoutError => e
      print "."
      retry
    end
    print "."
  end
  puts "done"
  # Watir.relaxed_locate = false
  browser.button(class: 'delete').wait_until_present
  puts "Clicking delete button"
  browser.button(class: 'delete').click
  browser.button(class: 'button', text: 'Delete').wait_until_present
  puts "Clicking REAL delete button"
  browser.button(class: 'button', text: 'Delete').click
  print "Waiting for delete to finish..."
  begin
    browser.span(class: 'icon-spinner').wait_while_present
  rescue Watir::Wait::TimeoutError => e
    print "."
    retry
  end
  puts "done"
end

headless = Headless.new
headless.start

browser = Watir::Browser.new

if login(browser)
  while trash_count(browser) > 0
    begin
      empty_trash(browser)
    rescue Exception => e
      $stderr.puts e.inspect
      sleep(DEFAULT_SLEEP)
      retry
    end
  end
else
  puts "Login failure"
end

browser.close
headless.destroy
