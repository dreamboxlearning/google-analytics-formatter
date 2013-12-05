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

class FlashAnalytics extends Analytics

  @default_dimensions = [
    'ga:year',
    'ga:month',
    'ga:flashVersion',
    'ga:operatingSystem',
    'ga:operatingSystemVersion',
  ]

  generate_flash_counts_from_data: (data, flash_counts) ->
    flash_counts.by_version = {} unless flash_counts.by_version
    flash_counts.monthly_totals = {} unless flash_counts.monthly_totals
    flash_counts.time_slices = [] unless flash_counts.time_slices
    total = 0

    for row in data
      [year, month, flash_full_version, os_name, os_version, count] = row
      flash_data = /^(\d+\.\d+) (.+)$/.exec(flash_full_version)
      if flash_version isnt '(not set)' and flash_data is null
          continue
      else if flash_version is '(not set)'
          flash_version = flash_full_version
      else
          flash_version = flash_data[1]

      year_month = "#{year}/#{month}"
      if year_month not in flash_counts.time_slices
        flash_counts.time_slices.push(year_month)
        flash_counts.monthly_totals[year_month] = 0

      flash_counts.by_version[flash_version] = {} if flash_version not of flash_counts.by_version
      flash_counts.by_version[flash_version][os_name] = {} if os_name not of flash_counts.by_version[flash_version]
      flash_counts.by_version[flash_version].total = {} if 'total' not of flash_counts.by_version[flash_version]
      flash_counts.by_version[flash_version][os_name][year_month] = 0 if year_month not of flash_counts.by_version[flash_version][os_name]
      flash_counts.by_version[flash_version].total[year_month] = 0 if year_month not of flash_counts.by_version[flash_version].total
      n_ct = Number(count)
      flash_counts.by_version[flash_version][os_name][year_month] += n_ct
      flash_counts.by_version[flash_version].total[year_month] += n_ct
      flash_counts.monthly_totals[year_month] += n_ct

    return flash_counts

  counts_to_wikitext: (lefthand_header, counts, time_slices, monthly_totals) ->
    wikitext = '{|border=1 style="text-align: center"\n'
    wikitext += "! Time Period / #{lefthand_header}\n"
    for time_slice in time_slices
      wikitext += "! #{time_slice}\n"
    totals = {}
    for flash_version, fv_data of counts
      totals[flash_version] = {}
      valid_percentages = 0
      totals[flash_version].total = {}
      for flash_os, fo_data of fv_data
        totals[flash_version][flash_os] = {}
        for time_slice in time_slices
          count = fo_data[time_slice] || 0
          percentage = Math.round(count / monthly_totals[time_slice] * 10000) / 100
          totals[flash_version][flash_os][time_slice] = percentage
          totals[flash_version].total[time_slice] = 0 unless totals[flash_version].total[time_slice]
          valid_percentages++ if percentage >= 1
      delete totals[flash_version] unless valid_percentages

    for flash_version, fv_data of totals
      wikitext += '|-\n'
      wikitext += "! #{flash_version}\n"
      for time_slice in time_slices
        wikitext += '| valign="top" |\n'
        if fv_data.total[time_slice] isnt 0
          wikitext += '  {|\n'
          wikitext += '  ! TOT\n'
          wikitext += "  ! #{Math.round(fv_data.total[time_slice] * 100) / 100}\n"
          for flash_os, fo_data of fv_data
            switch flash_os
              when 'total' then continue
              when 'Macintosh' then flash_os = 'Mac'
              when 'Windows' then flash_os = 'Win'
              when 'Linux' then flash_os = 'Lin'
              when 'Chrome OS' then flash_os = 'C OS'
              when 'BlackBerry' then flash_os = 'BB'
              when 'Google TV' then flash_os = 'GTV'
              when 'Android' then flash_os = 'Adrd'
              when 'Playstation 3' then flash_os = 'PS3'
              when 'Firefox OS' then flash_os = 'FF OS'
              when 'FreeBSD' then flash_os = 'FBSD'
              when '(not set)' then flash_os = '??'
            percentage = fo_data[time_slice]
            continue if percentage is 0
            wikitext += '  |-\n'
            wikitext += "  ! #{flash_os}\n"
            wikitext += "  | #{percentage}\n"
          wikitext += '  |}\n'
    wikitext += '|}\n'
    return wikitext
