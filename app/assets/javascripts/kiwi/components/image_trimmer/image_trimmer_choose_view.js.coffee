FK.App.module 'ImageTrimmer', (ImageTrimmer, App, Backbone, Marionette, $, _) ->
  
  class this.ImageChooseView extends Marionette.ItemView
    template: FK.Template('image_trimmer_choose')
    className: 'image-trimmer-input-container'

    events:
      'click button': 'clickFileUploader'
      'change input[type="file"]': 'startImageTrimmerFromUpload'
      'paste .url-input': 'loadFileInInput'

    clickFileUploader: (e) =>
      e.preventDefault()
      @$('input[type="file"]').click()

    startImageTrimmerFromUpload: (evt) =>
      file = evt.target.files[0]

      if ! _.contains ImageTrimmer.validImageTypes(), file.type
        @controller.trigger 'new:image:bad:type', file.type
        return

      reader = new FileReader()

      reader.onload = (readFile) =>
        @model.newUploadedImage file, readFile.target.result

      reader.readAsDataURL(file)

    loadFileInInput: (e) =>
      _.delay(() =>
        @model.newRemoteImage @$('input.url-input').val()
      , 10)


    modelEvents:
      'change:source': 'clearIfSourceNotUrl'
      'change:url': 'refreshUrl'

    clearIfSourceNotUrl: (model, source) =>
      @$('input.url-input').val('') if source != 'remote'

    refreshUrl: (model, url) =>
      if model.get('source') is 'remote'
        @$('input.url-input').val(url)
