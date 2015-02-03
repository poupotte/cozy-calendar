ScheduleItem = require './scheduleitem'
client = require '../lib/client'

module.exports = class Event extends ScheduleItem

    fcEventType: 'event'
    startDateField: 'start'
    endDateField: 'end'
    urlRoot: 'events'


    defaults: ->
        details: ''
        description: ''
        place: ''
        links: ['']
        folder: ''
        tags: ['my calendar']

    getDiff: ->
        return @getEndDateObject().diff @getStartDateObject(), 'days'

    extractLinks: (details) ->
        links = []
        linksWithName = details.match(/\[[a-zA-Z0-9\-\.\ ]+\]\ (http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/g)
        linksWithName = [] if not linksWithName?
        for link in linksWithName
            # Avoid duplicates
            details = details.replace link, ''
        linksWithoutName = details.match(/(?!\]\ )(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/g)
        linksWithoutName = [] if not linksWithoutName?
        for link in linksWithName
            index = link.indexOf(']')
            links.push({"url":link.substring(index+2,link.length), "text": link.substring(1,index)})
        for link in linksWithoutName
            links.push({"url":link, "text": link})
        return links

    getLinks: ->
        details = @get "details"
        indexUrl = details.indexOf('URL(S) DU COURS')
        urls = []
        if indexUrl isnt -1
            indexFiles = details.indexOf('FICHIER(S) DU COURS')
            if indexFiles isnt -1
                details = details.substring indexUrl, indexFiles
            else
                details = details.substring indexUrl, details.length
            urls = @extractLinks details
        return urls

    getFiles: ->
        details = @get "details"
        indexFiles = details.indexOf('FICHIER(S) DU COURS')
        files = []
        if indexFiles isnt -1
            details = details.substring indexFiles, details.length
            details = details.replace 'FICHIER(S) DU COURS - ', ''
            details = details.split('\n')
            @path = details[0]
            return [@path]
        else
            return []

    getUrl: (callback) ->
        client.get "folders/#{@path}", (err, res, body) =>
            if err?
                callback err
            else
                @folder = res.responseText
                callback null, res.responseText


    # Update start, with values in setObj,
    # while ensuring that end stays after start.
    # @param setObj a object, with hour, minute, ... as key, and corrresponding
    # values, in the cozy's user timezone.
    setStart: (setObj) ->
        sdo = @getStartDateObject()
        edo = @getEndDateObject()

        @_setDate(setObj, sdo, @startDateField)

        # Check and put end after start.
        if sdo >= edo
            edo = sdo.clone().add 1, 'hour'

            @set @endDateField, @_formatMoment edo

    # Same as update start, for end field.
    setEnd: (setObj) ->
        sdo = @getStartDateObject()
        edo = @getEndDateObject()

        @_setDate(setObj, edo, @endDateField)

        # Check start is before end, and move start.
        if sdo >= edo
            sdo = edo.clone().add -1, 'hour'

            @set @startDateField, @_formatMoment sdo

    _setDate: (setObj, dateObj, dateField) ->
        for unit, value of setObj
            dateObj.set unit, value

        @set dateField, @_formatMoment dateObj

    setDiff: (days) ->
        edo = @getStartDateObject().startOf 'day'
        edo.add days, 'day'

        if not @isAllDay()
            oldEnd = @getEndDateObject()
            edo.set 'hour', oldEnd.hour()
            edo.set 'minute', oldEnd.minute()

            # Check and put end after start.
            sdo = @getStartDateObject()
            if sdo >= edo
                edo = sdo.clone().add 1, 'hour'

        @set @endDateField, @_formatMoment edo

    validate: (attrs, options) ->

        errors = []

        unless attrs.description?
            errors.push
                field: 'description'
                value: "no summary"

        if not attrs.start or not (start = moment(attrs.start)).isValid()
            errors.push
                field: 'startdate'
                value: "invalid start date"

        if not attrs.end or not (end = moment(attrs.end)).isValid()
            errors.push
                field: 'enddate'
                value: "invalid end date"

        if start.isAfter end
            errors.push
                field: 'date'
                value: "start after end"

        return errors if errors.length > 0

    #@TODO tags = color
    getDefaultColor: -> '#008AF6'
