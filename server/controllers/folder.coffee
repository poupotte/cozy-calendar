Folder = require '../models/folder'

module.exports.getUrl = (req, res) ->
    path = req.params.path
    path = path.replace '.', '/'
    path = path.replace '.', '/'
    Folder.request 'byFullPath', {key: "/" + path}, (err, folders) ->
        return res.send error: err, 500 if err
        if folders.length is 0
            res.send "Folder not found", 404
        else
            res.send "files/folders/#{folders[0].id}"
