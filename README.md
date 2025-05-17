# cordova-plugin-save-file-stream

## Description
Take in source path, file name and file type and opens a save dialoag to the users files with the suggested name. Once the user selects a location the file is streamed to the new location in the app layer not the webview. 

## Installation

`cordova plugins add cordova-plugin-save-file-stream@latest --variable USESWIFTLANGUAGEVERSION = 5


## Usage

```js
 cordova.plugins.streamSave.exportFile({
    sourcePath: file.pathname,
    suggestedName: file.name,
    mimeType: file.type
}).then(() => {
    //...
}).catch(e => {
    console.error(e)
});
```

Type definitions are found in index.d.ts