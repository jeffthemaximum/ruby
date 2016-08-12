# Current Issues

- 1 - Need to sanatize params in `app/controllers/file_attachment_controller.rb`
  + http://stackoverflow.com/a/21886874
  + commit ec371dffb8e2144312f8e5f9683b4d5e54cdbb16
- 2 - Need to create a `def destroy` controller in `app/controllers/file_attachment_controller.rb`
  + https://github.com/jeffthemaximum/ruby/blob/master/rails/controllers/def_destroy.md
  + commit d8630337de499b5d83830aa8d594ff8fea91906e
  + TODO - still need to check if current user owns attachment
- 3 - Need to display the uploaded file attachments somehow on the frontend in `views/updates/new.html.erb` after a user has uploaded an attachment
  + commit 7ab0ce557ac307a13d7ab2711af8d0642e494b28
- 4 - Need to display the uploaded file attachments somehow on the frontend in the template rendered by `def share` in `updates_controller.rb`
  + 8b8ded2ad18addf1bcf2fa34a6d02358fb64a7d0
  + commit 5077ca4eb29a4b1299421bd4d5a4da1997eb4409
- 5 - Display button to delete file attachment on `views/updates/new.html.erb`
  + commit 6358f378bba471c92a6b1c7fc758a12c911dcd0c
- 6a - display file attachments on template rendered in the template rendered by `def edit` in `updates_controller.rb`
  + commit 5077ca4eb29a4b1299421bd4d5a4da1997eb4409
- 6 - Display button to delete file attachment in the template rendered by `def edit` in `updates_controller.rb`
  + commit 5077ca4eb29a4b1299421bd4d5a4da1997eb4409
- 7 - break out the code in `def create` in `app/controllers/updates` that iterates over the file_attachment_ids into it's own method so it's not cluttering the controller
  + commit 72de814b6ce44dbefe592d489c577f6e22794bbe
- 8 - Add validators to all models in `app/models/files/...`
- 9 - Put `has_many :file_attachments` associations in `User` and `Project` models
  + commit 8997415927d93e617621e9ec382024e9fb48068b
- 10 - Document how to add a `Add Upload` button to other pages, ideally like an upload API
- 11 - Add other file types, `PDF` and `CSV`
  + commit 7612dfd79495059885f470a5b95310d172838677
- 12 - Add file upload functionality to `project` pages, not just updates
- 13 - need to check that file attachment belongs to user in `def create` of `updates_controller.rb`
    * commit af1d36cc0923634e54d803c9b2f02cc43f69e699
- 14 - What happens if user uplaods attachments on updates#new then leaves page? should u delete them? should u query for attachments before loading new?
  + delete it
  + https://www.filestack.com/docs/file-ingestion/javascript-api/remove
- 15 - handle generic file attachments (not img or pdf)
  + commit 7612dfd79495059885f470a5b95310d172838677
- 16 - user can drag/drop file attachment onto text field for upload. doesn't go inline, but does upload
- 17 - add styles to file attachments in templates
  + several commits, ending with...
  + commit 8a1bac4d48856e7beb0c06a8d863fb528e4fde0a
- 18 - style filepicker upload modal
- 19 - limit file upload size. see here: https://www.filestack.com/docs/file-ingestion/javascript-api/pick ... Max size

# FAQ's

### Why 2 AJAX calls in `app/assets/javascripts/file_attachments/file_attachments.js`?

- There's one call to `/upload` and another to `/file_attachment/create`
- One reason is that there was already a `def create` controller in `app/controllers/uploads_controller` and already a `Upload` model in `app/models/upload.rb` and I wanted to reuse as much of this code as possible
- Another reason is that we create two different models, and `Upload` model and a `FileAttachment` model. It makes sense to have two difference endpoints for these two different pieces of logic
- A third reason is extensibility. We don't want to tie the creation of `FileAttachment`s to `Upload`s, because it lets us more flexibly create other subclasses of `FileAttachent`s in the future.

### Why store the file_attachment ID's in a hidden field in the form in `app/views/updates/_update_fields.html.erb`

- They get stored here in this HTML element:
```
<%= f.hidden_field :file_attachment_ids, value: '[]' %>
```
- By the `createFileAttachment` function in `app/assets/javascripts/file_attachments/file_attachments`
- It's a sorta complicated reason why.
- When the user uploads a file attachment in `views/updates/new.html.erb`, the `Update` object hasn't been created or saved to the DB yet.
- The `FileAttachment` model that's created at this point should have an associated `target` field, which would contain the `target_id`, in this case, the ID of the `Update` that the FileAttachment is associated with.
- We can't store that `update.id` with the `file_attachment.target_id` field yet because that `update` hasn't been created or saved.
- So the `createFileAttachment` created the `FileAttachment` model but doesn't save anything in the `target_id` or `target_type` columns, yet.
- We store all the Id's in the `<%= f.hidden_field :file_attachment_ids, value: '[]' %>` HTML field.
- Then, when the user submits the form in `views/updates/new.html.erb`, we send along all the file_attachment ID's.
- In the controller called by that form, `def create` in `app/controllers/updates` we run these codes to associate all the file_attachments with the update:

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

