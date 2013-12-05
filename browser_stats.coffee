###!
Copyright (c) 2013 DreamBox Learning, Inc.
MIT License
###
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Author: Mark Lee

class BrowserAnalytics extends Analytics

  @default_dimensions = [
    'ga:year',
    'ga:month',
    'ga:browser',
    'ga:browserVersion',
    'ga:isMobile',
  ]

  generate_browser_key: (browser, version) ->
    switch browser
      when 'Internet Explorer' then "IE #{version}"
      when 'Mozilla'
        if version is '11.0'
          # Google Analytics is being stupid
          # See: http://productforums.google.com/forum/#!msg/analytics/xepcZ5Ki5TQ/PUnE7PTviT8J
          "IE #{version}"
        else
          browser
      #when 'Firefox' then "#{browser} #{/^\d+\.\d/.exec(version)[0]}"
      when 'Mozilla Compatible Agent', 'Safari (in-app)' then 'iPhone'
      #when 'Safari'
      #  # see http://en.wikipedia.org/wiki/Safari_version_history
      #  bversion = switch version
      #    when '48' then '0.8'
      #    when '73' then '0.9'
      #    when '85', '85.8.3' then '1.0.x'
      #    when '100' then '1.1'
      #    when '125' then '1.2'
      #    when '312', '312.3', '312.5', '312.6' then '1.3.x'
      #    when '412', '416.11', '419.3' then '2.0.x'
      #    when '522.11', '522.11.3', '522.12', '522.12.1', '522.12.2', '522.13.1', '522.15.5', '523.10', '523.12.9', '523.13', '523.15' then '3.0.x'
      #    when '525.13', '525.17', '525.20', '525.21' then '3.1.x'
      #    when '525.26', '525.26.13', '525.27', '525.27.1', '525.28', '525.28.1', '525.29.1' then '3.2.x'
      #    when '526.11.2', '526.12.2', '528.1.1', '528.16', '528.17', '530.17', '530.18', '530.19', '530.19.1', '531.9', '531.9.1', '531.21.10', '531.22.7' then '4.0.x'
      #    when '533.16', '533.17.8' then '4.1.x or 5.0.x'
      #        #if os_name is 'Macintosh' # TODO and os_version is '10.4'
      #        #    '4.1.x'
      #        #else
      #        #    '5.0.x'
      #    when '533.18.5', '533.19.4', '533.20.7', '533.21.1', '533.22.3' then '5.0.x'
      #    when '534.48.3', '534.50', '534.51.22', '534.52.7' then '5.1.x'
      #    when '6533.18.5' then '5.0.x (iOS4.2)'
      #    when '7534.48.3' then '5.1.x (iOS5)'
      #    else version
      #  "#{browser} #{bversion}"
      else browser

  generate_browser_counts_from_data: (data, browser_counts) =>
    browser_counts.by_browser = {} unless browser_counts.by_browser
    browser_counts.monthly_totals = {} unless browser_counts.monthly_totals
    browser_counts.time_slices = [] unless browser_counts.time_slices
    for row in data
      [year, month, browser, version, is_mobile, count] = row
      year_month = "#{year}/#{month}"
      if year_month not in browser_counts.time_slices
        browser_counts.time_slices.push(year_month)
        browser_counts.monthly_totals[year_month] = 0
      device_type = if is_mobile == 'Yes' then 'mobile' else 'desktop'
      browser_counts.by_browser[device_type] = {} if device_type not of browser_counts.by_browser
      browser_key = this.generate_browser_key(browser, version)
      browser_counts.by_browser[device_type][browser_key] = {} if browser_key not of browser_counts.by_browser[device_type]
      browser_counts.by_browser[device_type][browser_key][year_month] = 0 if year_month not of browser_counts.by_browser[device_type][browser_key]
      n_ct = Number(count)
      browser_counts.by_browser[device_type][browser_key][year_month] += n_ct
      browser_counts.monthly_totals[year_month] += n_ct

    return browser_counts
