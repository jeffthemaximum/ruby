- This is my attempt to document the flow of a file upload on updates/new.
- My goal was to create a reusable html button that could basically be plopped on any page.

# Flow of a file attachment from updates/new

### The file attachment button

- We start by pointing the browser at an update/new page, such as `/projects/sea-turtle-egg-fusariosis-unraveling-the-biology-of-an-emerging-fungal-pathogen/updates/new`
- This loads the html template in `views/updates/new.html.erb`
- `views/updates/new.html.erb` loads `views/updates/_edit_form.html.erb`
- `views/updates/_edit_form.html.erb` contains this button:

```
  <button 
    class="newbtn newbtn-primary add-button" 
    id="fileAttachment" 
    data-user-id="<%= @author.id %>" 
    data-project-id="<%= @project.id %>">
      Add Attachment
  </button>
```

- There's two things that we need to include as data-attributes on the `Add Attachment` button, the `data-user-id` and the `data-project-id`.
- When the user clicks this button, we load codes in `app/assets/javascripts/file_attachments/file_attachments.js`

### Aside: How does that code in `app/assets/javascripts/file_attachments/file_attachments.js` get loaded by `views/updates/new.html.erb`??

- Since we're not using nucleus (YET!) for `views/updates/new.html.erb`...
- I added this line to `app/views/layouts/_footer.html.erb`:

```
= javascript_include_tag params[:controller]
```

- This loads a JS file of the name of the controller into all views.
- That means `views/updates/new.html.erb` will load `app/assets/javascripts/updates.js` automatically, since it's called from the `def new` controller in `app/controllers/updates_controller.rb`
- `app/assets/javascripts/updates.js` looks like this:

```
//= require file_attachments/file_attachments
```

- So, it's what loads `app/assets/javascripts/file_attachments/file_attachments.js`

### File upload via FilePicker

- In `app/assets/javascripts/file_attachments/file_attachments.js`, we have these codes:

```
$('#fileAttachment').on('click', function(e) {
  e.preventDefault();
  var userId = $(this).data('user-id');
  initFilePicker(userId);
})
```

- This catches the click event on the button with id `fileAttachment`.
- It then fires the `initFilePicker` function and passes the user's id.
- `initFilePicker` looks like these codez:

```
var initFilePicker = function(userId) {
  if(userId) {
    storeOptions.path = userId + '/file-attachments/';
  }
  app.initFilePicker(function() {
    filepicker.pickAndStore(pickerOptions, storeOptions, this.onSuccess, this.onError, this.onProgress);
  }.bind(this));
};
```

- It calls the `app.initFiePicker` function (which is in `app/assets/javascripts/app.js`, and which was written before this PR...)
- `app.initFilePicker`'s callback fires `filepicker.pickAndStore(pickerOptions, storeOptions, this.onSuccess, this.onError, this.onProgress);`
- `filepicker.pickAndStore...` opens the modal and lets the user upload a file to the `storeOptions.path`
- it fires the `onSuccess` function, which looks like this:

```
var onSuccess = function(blob, bar) {
  console.log('yay!');
  createUpload(blob);
};
```

- Which basically just calls the `createUpload` function.
- `createUpload` looks like this:

```
var createUpload = function(blob) {
  
  var s3Path = blob[0].key;
  var fileType = mimeConverter(blob[0].mimetype);

  var params = {
    s3_path: s3Path,
  };

  $.ajax("/upload", {
    method: 'post',
    dataType: 'json',
    data: params,
    
    success: function(data) {
      createFileAttachment(data, fileType);
    }.bind(this),
    error: function(error) {
      // TODO - display error on page for user
      deferred.reject(error);
    }.bind(this)
  });

  return deferred.promise();
};
```

- the `fileType` here comes from the `mimetype` returned by `filepicker.pickAndStore...`
- `mimeCoverter` is a function that looks like this:
- 
```
var mimeConverter = function(mimetype) {
  if (substringInString(mimetype, 'img/') || substringInString(mimetype, 'image/')) {
    fileType = "ImageAttachment";
  } else {
    fileType = "Unsupported";
  };
  return fileType;
};
```

- The important this here is that the `fileType` that is returned by `mimeConverter` must correspond to a `Model` in `app/models/files`
- For example, right now I'm just uploading images, so `image_attachment.rb` in `app/models/files/` has a class `ImageAttachment`

- `createUpload` makes the `$.ajax` call to `/upload`
- It passes the s3_path that's returned from `filepicker.pickAndStore...`
- It calls the `def create` controller in `app/controllers/uploads`

### Rails upload#create

- This was written before me, so I won't document it too much here.
- Basically, it takes an `s3_path` as a string, creates an instance of `Upload`, and returns a JSON response with that's instances `:id, :url`

### back to `createUpload` in `app/assets/javascripts/file_attachments/file_attachments.js`

- `success` calls `createFileAttachment(data, fileType)`, passing the `:id, :url` and the `Upload` instance as `data` and passing the `fileType`.

- `createFileAttachment` looks like this:

```
var createFileAttachment = function(blob, fileType) {

  var projectId = $('#fileAttachment').data('project-id');
  var uploadId = blob.id;

  var params = {
    file_type: fileType,
    project_id: projectId,
    upload_id: uploadId
  };

   $.ajax("/file_attachment/create", {
    method: 'post',
    dataType: 'json',
    data: params,
    success: function(data) {
      var fileAttachmentIds = JSON.parse($('#update_file_attachment_ids').val());
      fileAttachmentIds.push(data['id']);
      var jsonFileAttachmentIds = JSON.stringify(fileAttachmentIds);
      $('#update_file_attachment_ids').val(jsonFileAttachmentIds);
    }.bind(this),
    error: function(error) {
      // TODO display error on page for user
      deferred.reject(error);
    }.bind(this)
  });
};
```

- `uploadId` comes from the JSON returned from `def create` in `uploads_controller.rb`
- `projectId` comes from the data attribute of the `Attach Upload` HTML button previously described.
- `createFileAttachment` makes the `$.ajax` call to `/file_attachment/create` and passes `params`

### `def create` in `app/controllers/file_attachment_controller.rb`

- Looks like this

```
class FileAttachmentController < ApplicationController
  def create
    klass = Object.const_get params[:file_type] if allowed_types.include? params[:file_type]
    file_attachment = klass.create! do |fa|
      fa.user = current_user
      # TODO santitize these params?
      fa.upload = Upload.find(params[:upload_id])
      fa.project = Project.find(params[:project_id].to_i)
    end
    render json: file_attachment.slice(:id)
  end

  private
    def file_attachment_params
      params.permit(:target_type)
    end

    def allowed_types
      ['ImageAttachment']
    end
end
```

- It gets the class of class of model to create from the string stored in `params[:file_type`
- This is why it's important that the String returned by `mimeConverter` in `app/assets/javascripts/file_attachments/file_attachments.js` corresponds syntactically with the name of a Model that inherits from `FileAttachment` in our Rails app. All these models are stored in `app/models/files`
- It creates an instance of that whatever model `klass` is.
- It stores relationships to the `user`, `upload`, and `project` associated with the `FileAttachment`
- It returns the `id` of the `file_attachment` object.

### back to `createFileAttachment` in `app/assets/javascripts/file_attachments/file_attachments.js`

- The `success` function in `createFileAttachment` does these codez:

```
var fileAttachmentIds = JSON.parse($('#update_file_attachment_ids').val());
fileAttachmentIds.push(data['id']);
var jsonFileAttachmentIds = JSON.stringify(fileAttachmentIds);
$('#update_file_attachment_ids').val(jsonFileAttachmentIds);
```

- `$('#update_file_attachment_ids')` grabs the `value` of the `hidden_field` with id `update_file_attachment_ids` that I added to the form in `app/views/updates/_update_fields.html.erb`
- `$('#update_file_attachment_ids').val()` is a JSON array contained the `id`'s of all the `FileAttachment` instances that are created while a user is on the `views/updates/new.html.erb` page.
- `fileAttachmentIds.push(data['id']);` adds the id of the current `FileAttachment` to the array of ID's stored in `'#update_file_attachment_ids').val()`
- `var jsonFileAttachmentIds = JSON.stringify(fileAttachmentIds);` turns that array back into a string.
- `$('#update_file_attachment_ids').val(jsonFileAttachmentIds);` updates the `value` of the `hidden_field` with id `update_file_attachment_ids`.

### When user submits form from `views/updates/new.html.erb` to `def create` in `app/controllers/updates_controller.rb`

- When the user submits the new update form, there's a hidden field in it, as described above, containing an array zero or more of the `FileAttachment` id's
- The `params` passed to this controller from the form look like this:

```
{"utf8"=>"✓",
 "authenticity_token"=>
  "TErTiifgdpqe7LllqqplaMC3VMQye4ttZu6VzsehbVPmUMek4W5APW7whYS9j7/JLXEiAxKy+aqYPsPN2ky8KA==",
 "update"=>
  {"title"=>"test",
   "update_text"=>"<p>test</p>",
   "user_id"=>"51416",
   "backers_only"=>"0",
   "project_file_ids"=>"",
   "publish_on"=>"",
   "publish_now"=>"true",
   "file_attachment_ids"=>"[17]",
   "prod_type"=>""},
 "controller"=>"updates",
 "action"=>"create",
 "project_id"=>"sea-turtle-egg-fusariosis-unraveling-the-biology-of-an-emerging-fungal-pathogen"}
```

- Notice here the `"file_attachment_ids"=>"[17]"`
- `def create` in `app/controllers/updates_controller.rb` already existed before this PR. I added these lines to it:

```
file_attachment_ids = JSON.parse(params[:update][:file_attachment_ids])
  if file_attachment_ids.any?
    file_attachment_ids.each do |fa_id|

      # find file attachment by id
      fa = FileAttachment.find(fa_id)

      # set target of that file attachment to this update
      fa.target = @update

      # save file attachment
      fa.save

    end
  end
```

- This converts the JSON list of `FileAttachment` id's to a ruby array.
- The iterates across the array
- Finds the relevant `FileAttachment` model
- Sets the `target` of the `fa` to the new `Update` instance
- Saves the `fa`
