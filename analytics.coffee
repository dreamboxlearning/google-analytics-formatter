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

class Analytics
  scopes: 'https://www.googleapis.com/auth/analytics.readonly'

  @init: (oncomplete) ->
    $ ->
      window.onGDataLoaded = oncomplete
      script = $ '<script>',
        src: 'https://apis.google.com/js/client.js?onload=onGDataLoaded'
      script.appendTo('head')

  # @end defaults to today
  constructor: (@client_id, @dropdowns, @authorize_btn, @dimensions, @count_generator, @stats_handler, @start, @end = new Date()) ->

  run: =>
    window.setTimeout =>
      @handle_authorize(true)
    , 1

  handle_authorize: (immediate) =>
    dd_metadata = @dropdowns
    that = this
    @authorize @client_id, @scopes, immediate, ->
      gapi.client.analytics.management.accounts.list().execute (accounts) ->
        that.dropdown_change_handler accounts, that.dropdowns.accounts, (account_id) ->
          that.account_id = account_id
          gapi.client.analytics.management.webproperties.list
            accountId: account_id
        , (properties) ->
          that.dropdown_change_handler properties, that.dropdowns.properties, (property_id) ->
            gapi.client.analytics.management.profiles.list
              accountId: that.account_id
              webPropertyId: property_id
          , (profiles) =>
            that.dropdown_change_handler profiles, that.dropdowns.profiles, (profile_id) =>
              beginning = new Date(that.start.getFullYear(), that.start.getMonth(), 1)
              end_of_last_month = new Date(that.end.getFullYear(), that.end.getMonth(), 0)
              args =
                ids: "ga:#{profile_id}"
                'start-date': that.date_to_iso_string(beginning)
                'end-date': that.date_to_iso_string(end_of_last_month)
                metrics: 'ga:visitors'
                dimensions: that.dimensions.join(',')
              that.paged_analytics(args, {}, 0, that[that.count_generator], that.stats_handler)
    , =>
      $(@authorize_btn).show().click =>
        @handle_authorize(false)
        return false

  populate_dropdown_with_gdata_list_results: (results, type, dropdown) ->
    if results.code
      console.error "Error querying #{type}: #{results.message}"
      return false
    return false unless results and results.items and results.items.length
    dropdown = $(dropdown)
    dropdown.children('option:not(:first)').remove()
    for item in results.items
      dropdown.append($('<option>',
        value: item.id
      ).text(item.name))
    dropdown.show()
    return dropdown

  dropdown_change_handler: (results, metadata, api_call, data_callback) =>
    dropdown = @populate_dropdown_with_gdata_list_results(results, metadata.type, metadata.selector)
    return unless dropdown
    dropdown.change ->
      value = $(this).val()
      return unless value
      if data_callback
        api_call(value).execute(data_callback)
      else
        api_call(value)

  date_to_iso_string: (input_date) ->
    year = input_date.getFullYear()
    month = input_date.getMonth() + 1 # zero-based
    month = "0#{month}" if month < 10
    day = input_date.getDate()
    day = "0#{day}" if day < 10
    return "#{year}-#{month}-#{day}"

  paged_analytics: (args, counts, offset, counts_generator, callback) =>
    args['start-index'] = offset if offset
    gapi.client.analytics.data.ga.get(args).execute (data) =>
      counts = counts_generator(data.rows, counts)
      running_total = Number(data.itemsPerPage) + offset
      if Number(data.totalResults) > running_total
        this.paged_analytics(args, counts, running_total, counts_generator, callback)
      else
        callback(counts)

  authorize: (client_id, scopes, immediate, success_callback, failure_callback) ->
    gapi.auth.authorize
      client_id: client_id
      scope: scopes
      immediate: immediate
    , (auth_result) ->
      unless auth_result
        failure_callback()
      else
        gapi.client.load 'analytics', 'v3', ->
          success_callback()

  counts_to_wikitext: (lefthand_header, counts, time_slices, monthly_totals) ->
    wikitext = '{|border=1 style="text-align: center"\n'
    wikitext += "! Time Period / #{lefthand_header}\n"
    for time_slice in time_slices
      wikitext += "! #{time_slice}\n"
    wikitext += '|-\n'
    totals = {}
    for count_key, count_data of counts
      totals[count_key] = {}
      valid_percentages = 0
      for time_slice in time_slices
        count = count_data[time_slice] || 0
        percentage = Math.round(count / monthly_totals[time_slice] * 10000) / 100
        totals[count_key][time_slice] = percentage
        valid_percentages++ if percentage >= 1
      delete totals[count_key] unless valid_percentages

    for count_key, count_data of totals
      wikitext += "! #{count_key}\n"
      for time_slice in time_slices
        percentage = count_data[time_slice]
        wikitext += "| #{percentage}\n"
      wikitext += '|-\n'
    wikitext += '|}\n'
    return wikitext

  print_counts_to_console: (lefthand_header, counts, time_slices, monthly_totals) ->
    console.log @counts_to_wikitext(lefthand_header, counts, time_slices, monthly_totals)

  print_counts_to_browser: (lefthand_header, counts, time_slices, monthly_totals, selector) ->
    $(selector).text(@counts_to_wikitext(lefthand_header, counts, time_slices, monthly_totals))
