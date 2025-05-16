var exec = require('cordova/exec');

var StreamSave = {
  /**
   * Streams a file from app storage to a user-selected location via native file picker
   *
   * @param {Object} options
   * @param {string} options.sourcePath - The cdvfile:// or file:// path to the source file
   * @param {string} options.suggestedName - Suggested filename to show in the save dialog
   * @param {string} options.mimeType - MIME type of the file
   * @returns {Promise<void>} Resolves when the file is saved
   */
  exportFile: function (options) {
    return new Promise(function (resolve, reject) {
      exec(resolve, reject, 'StreamSave', 'exportFile', [options]);
    });
  }
};

module.exports = StreamSave;