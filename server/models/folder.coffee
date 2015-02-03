americano = require 'americano-cozy'

module.exports = Folder = americano.getModel 'Folder',
    path: String
    name: String
    docType: String
    creationDate: String
    lastModification: String
    size: Number
    modificationHistory: Object
    changeNotification: Boolean
    clearance: (x) -> x
    tags: (x) -> x

Folder.byFullPath = (params, callback) ->
    Folder.request "byFullPath", params, callback