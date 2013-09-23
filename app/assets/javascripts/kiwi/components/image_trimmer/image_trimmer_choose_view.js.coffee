FK.App.module 'ImageTrimmer', (ImageTrimmer, App, Backbone, Marionette, $, _) ->
  
  class this.ImageChooseView extends Marionette.ItemView
    template: FK.Template('image_trimmer_choose')

    events:
      'change input[type="file"]': 'startImageTrimmerFromUpload'

    startImageTrimmerFromUpload: (evt) =>
      file = evt.target.files[0]
      reader = new FileReader()

      reader.onload = (readFile) ->
        ImageTrimmer.trigger 'new:image:url', readFile.target.result

      reader.readAsDataURL(file)
