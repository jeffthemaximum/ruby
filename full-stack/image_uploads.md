# Flow of an upload on spearmint

- The example we'll look at is user avatar upload


### JS

- user loads `user/50427/edit` in browser
- this template loads `app/components/avatar-upload/index.js.jsx` script
- This script creates this element

```
<div>
  <div className={classString} onClick={this.uploadAvatarImage}>
    <i className="fa fa-image"></i>
    <p className="avatar-instructions">
      Click to add a picture from your computer
    </p>
    <p className="avatar-constraints">
      Image must be .jpg, or .png and must be smaller than 10MB.
    </p>
  </div>
</div>
```

- Clicking this element fires the `uploadAvatarImage` function, which is also in `app/components/avatar-upload/index.js.jsx`
- `uploadAvatarImage` creates a filepicker modal, which is created with this codes
```
app.initFilePicker(function() {
  filepicker.pickAndStore(pickerOptions, storeOptions, this.onSuccess, this.onError, this.onProgress);
}.bind(this));
```
- `app.initFilePicker` comes from codes in `app/assets/javascripts/app.js`
- `filepickker.pickAndStore` contains the `this.onSuccess` method, which fires on successful upload from user's pooter.
- `filepickker.pickAndStore` returns the s3 key. In my case, the s3 key will be something like `"s3_path"=>"50427/mPfBQKZ8Qaid7uEGHOOZ_Screen Shot 2016-08-02 at 4.39.35 PM.png"` ... 
- `filepicker.pckAndStore` does two things (possibly more, but I know of at least two that it does...)
  - it uploads the file to AWS
  - it returns the s3_key
- To get a full aws URL from this, you'd concatenate your s3 URL with the s3 key ... "https://s3.amazonaws.com/your_own_bucket/" + s3key
- This s3 key gets passed to the `onSuccess` function.
- `onSuccess` first calls `ImageUploader.createUpload(blob);` ... where blob contains the s3 key
- `ImageUploader.createUpload(blob);` references code in `require('./../shared/image-uploader')` which is located at `app/assets/javascripts/components/shared/image-uploader.js`
- `createUpload(blob)` method looks like this, and is what makes the `$.ajax` call to the server
- This ajax call only passes the s3 url, not the image.

```
const ImageUploader = {

  createUpload(blob) {
    let deferred = $.Deferred();

    let params = {
      s3_path: blob[0].key
    };

    $.ajax("/upload", {
      method: 'post',
      dataType: 'json',
      data: params,
      success: function(data) {
        deferred.resolve(data);
      }.bind(this),
      error: function(error) {
        deferred.reject(error);
      }.bind(this)
    });

    return deferred.promise();
  }
}

module.exports = ImageUploader;
```
- It passes the s3_path to the server

### Rails

- From here, we his the `app/controllers/uploads_controller.rb` file and the `def create` function
- `def create` create the upload instance and saves to db.
- `def create` does not make this a `Images::ProjectCover`, `Images::UpdateContent`, `Images::UserAvatar`, however.
- On successful save, `def create` sends this json back to the JS --> `upload.slice(:id, :url)` ... basically the `upload.id` and the `upload.url`

### Back to JS

- `ImageUploader.createUpload(blob);` makes the AJAX call described above.
- It's a promise, so when it's complete, if fires `.then(function(createUploadResult){`
- `createUploadResult` is the `upload.slice(:id, :url)` json returned from `def create` in the `app/controllers/uploads_controller.rb`
- the `then` function fires the `createUserAvatar`
- `createUserAvatar` makes a `$.ajax` post request to `this.state.url` which somehow gets translated to `/users/50427/avatar`

### Back to Rails

- Rails routes this to the `def create` controller function in `app/controllers/users/avatars_controllers.rb`
- Lines 11-14 here are where we create the `Images::UserAvatar` and link it to the `upload` instance we created with the earlier ajax call to `/upload`. With these codes:

```
avatar = Images::UserAvatar.find_or_initialize_by user: user
upload = Upload.find params[:upload][:id]

avatar.update_attributes! upload: upload
```

### The end
- At this point, we've uploaded an image to s3, saved it's url to the server, created an instance of an `Upload`, created an instance of a `Images::UserAvatar`, and linked those two instances via foreign keys.