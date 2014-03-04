alarms = require './alarms'
events = require './events'
contacts = require './contacts'
index  = require './index'
ical   = require './ical'


module.exports =

    '' : get : index.index
    'tags': get : index.tags

    # Alarm management
    'alarms':
        get   : alarms.all
        post  : alarms.create
    'alarmid':
        param : alarms.fetch
    'alarms/:alarmid':
        get   : alarms.read
        put   : alarms.update
        del   : alarms.delete

    # Event management
    'events':
        get   : events.all
        post  : events.create
    'eventid':
        param : events.fetch
    'events/:eventid':
        get   : events.read
        put   : events.update
        del   : events.delete

    'events/:eventid/:name.ics':
        get   : events.ical
    'public/events/:eventid/:name.ics':
        get   : events.publicIcal
    'public/events/:eventid':
        get   : events.public

    # ICal
    'export/calendar.ics':
        get   : ical.export
    'import/ical':
        post  : ical.import
    'public/calendars/:calendarname.ics':
        get   : ical.calendar

    # Contacts
    'contacts':
        get: contacts.list
