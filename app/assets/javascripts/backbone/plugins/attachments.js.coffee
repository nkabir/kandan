class Kandan.Plugins.Attachments

  @widget_title: "Media"
  @plugin_namespace: "Kandan.Plugins.Attachments"

  @template: _.template('''
    <form accept-charset="UTF-8" action="/channels/<%= channel_id %>/attachments.json" data-remote="true" html="{:multipart=&gt;true}" id="file_upload" method="post">
      <div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="✓">
        <input name="<%=csrf_param %>" type="hidden" value="<%= csrf_token %>"/>
      </div>
      <input id="channel_id_<%= channel_id %>" name="channel_id[<%= channel_id %>]" type="hidden"/>
      <input id="file" name="file" type="file"/>
      <div class="dropzone">Drop files here to upload</div>
   </form>
  ''')

  @supports_drop_upload: ()->
    !!(window.File && window.FileList && window.FileReader)

  @channel_id: ()->
    Kandan.Data.Channels.activeChannelId()

  @csrf_param: ->
    $('meta[name=csrf-param]').attr('content')

  @csrf_token: ->
    $('meta[name=csrf-token]').attr('content')

  @file_item_template: _.template '''
    <li><a href="<%= url %>"><%= file_name %></a></li>
  '''

  # TODO this part is very bad for APIs! shoudnt be exposing a backbone collection in a plugin.
  @render: ($widget_el)->
    $upload_form = @template({
      channel_id: @channel_id(),
      csrf_param: @csrf_param(),
      csrf_token: @csrf_token()
    })

    $widget_el.next().html($upload_form)
    @init_dropzone @channel_id()
    console.log $widget_el.next()
    $widget_el.next(".action_block").html($upload_form)
    $file_list = $("<ul></ul>")
    attachments = new Kandan.Collections.Attachments([], {channel_id: @channel_id()})
    attachments.fetch({success: (collection)=>
      for model in collection.models
        $file_list.append(@file_item_template({
          file_name: model.get('file_file_name'),
          url: model.get('url')
        }))
      $widget_el.html($file_list)
    })


  @init_dropzone: (channel_id)->
    $(".dropzone").filedrop({
      fallback_id: "file"
      url        : "/channels/#{channel_id}/attachments.json",
      paramname  : "file"

      uploadStarted: =>
        $(".dropzone").text("Uploading...")

      uploadFinished: (i, file, response, time)->
        $(".dropzone").text("Drop files here to upload")
        Kandan.Widgets.render "Kandan.Plugins.Attachments"

      dragOver: ->
        console.log "reached dropzone!"
    })

  @init: ()->
    Kandan.Widgets.register @plugin_namespace
    Kandan.Data.Channels.register_callback "change", ()=>
      Kandan.Widgets.render @plugin_namespace


# Kandan.Plugins.register "Kandan.Plugins.Attachments"